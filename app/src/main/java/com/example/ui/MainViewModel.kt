package com.example.ui

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.AppDatabase
import com.example.data.Masterpiece
import com.example.data.MasterpieceRepository
import com.example.api.GeminiClient
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

sealed interface EditUiState {
    object Idle : EditUiState
    object Loading : EditUiState
    data class Success(val masterpiece: Masterpiece, val feedback: String) : EditUiState
    data class Error(val message: String) : EditUiState
}

class MainViewModel(application: Application) : AndroidViewModel(application) {
    private val database = AppDatabase.getDatabase(application)
    private val repository = MasterpieceRepository(database.masterpieceDao())

    // Currently active tab: "discover", "gallery", "community", "profile"
    private val _activeTab = MutableStateFlow("discover")
    val activeTab: StateFlow<String> = _activeTab.asStateFlow()

    // Prompt input
    private val _prompt = MutableStateFlow("")
    val prompt: StateFlow<String> = _prompt.asStateFlow()

    // Private state for creation flow
    private val _isPrivate = MutableStateFlow(false)
    val isPrivate: StateFlow<Boolean> = _isPrivate.asStateFlow()

    // Selected Tool (风格迁移, 换脸, AI 扩图, 物体移除)
    private val _selectedTool = MutableStateFlow("风格迁移")
    val selectedTool: StateFlow<String> = _selectedTool.asStateFlow()

    // UI generation state
    private val _editUiState = MutableStateFlow<EditUiState>(EditUiState.Idle)
    val editUiState: StateFlow<EditUiState> = _editUiState.asStateFlow()

    // Selected masterpiece for detail modal view
    private val _selectedMasterpiece = MutableStateFlow<Masterpiece?>(null)
    val selectedMasterpiece: StateFlow<Masterpiece?> = _selectedMasterpiece.asStateFlow()

    // Database flow of masterpieces
    val allMasterpieces: StateFlow<List<Masterpiece>> = repository.allMasterpieces
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    val publicMasterpieces: StateFlow<List<Masterpiece>> = repository.publicMasterpieces
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    // Help QA values
    private val _helpAnswer = MutableStateFlow<String>("")
    val helpAnswer: StateFlow<String> = _helpAnswer.asStateFlow()

    private val _helpLoading = MutableStateFlow(false)
    val helpLoading: StateFlow<Boolean> = _helpLoading.asStateFlow()

    init {
        viewModelScope.launch {
            repository.populateInitialDataIfEmpty()
        }
    }

    fun setTab(tab: String) {
        _activeTab.value = tab
    }

    fun setPrompt(text: String) {
        _prompt.value = text
    }

    fun setPrivate(value: Boolean) {
        _isPrivate.value = value
    }

    fun setTool(tool: String) {
        _selectedTool.value = tool
    }

    fun selectMasterpiece(item: Masterpiece?) {
        _selectedMasterpiece.value = item
    }

    fun clearEditState() {
        _editUiState.value = EditUiState.Idle
    }

    fun deleteMasterpiece(id: Int) {
        viewModelScope.launch {
            repository.deleteById(id)
            if (_selectedMasterpiece.value?.id == id) {
                _selectedMasterpiece.value = null
            }
        }
    }

    fun performAiEdit() {
        val currentPrompt = _prompt.value.trim()
        val currentTool = _selectedTool.value
        val currentPrivate = _isPrivate.value

        if (currentPrompt.isEmpty()) {
            _editUiState.value = EditUiState.Error("请输入创作提示词后进行AI修图")
            return
        }

        _editUiState.value = EditUiState.Loading

        viewModelScope.launch {
            // Select curated image asset URL depending on user's prompt and selected tool
            val imageUrl = selectCuratedImage(currentPrompt, currentTool)

            // Construct system instruction to get a highly customized artistic description from Gemini
            val systemInstruction = """
                你是一个资深的艺术评论家和艺术故事述说者。
                请根据用户选择的修图工具【$currentTool】和创作提示词【$currentPrompt】，写一段对所生成的数字美术作品的优美、诗意艺术描述。
                你需要描述这件作品的视觉效果、光影变幻、色彩搭配、笔触纹理以及隐藏的艺术概念寓意。
                语言要深邃优雅，极具艺术大师感，务必使用中文。
                段落控制在两段以内，总字数不要超过180字。
            """.trimIndent()

            val promptCommand = "请为使用了【$currentTool】工具、基于提示词【$currentPrompt】生成的艺术作品撰写视觉分析。"

            val feedbackText = GeminiClient.generate(promptCommand, systemInstruction)

            if (feedbackText == "ApiKeyError") {
                _editUiState.value = EditUiState.Error("API Key未设置。请在'我的-API设置'或后台Secrets控制面板中配置您的GEMINI_API_KEY。")
                return@launch
            }

            if (feedbackText.startsWith("Error:")) {
                _editUiState.value = EditUiState.Error(feedbackText.removePrefix("Error:"))
                return@launch
            }

            // Successfully generated! Save this to the database
            val autoTitle = if (currentPrompt.length > 8) currentPrompt.take(8) + "..." else currentPrompt
            val newWork = Masterpiece(
                title = autoTitle,
                prompt = currentPrompt,
                toolType = currentTool,
                imageUrl = imageUrl,
                isPrivate = currentPrivate,
                authorName = "AI_Designer_01"
            )

            repository.insert(newWork)
            _editUiState.value = EditUiState.Success(newWork, feedbackText)
        }
    }

    fun askHelpQuestion(question: String) {
        _helpLoading.value = true
        _helpAnswer.value = ""
        viewModelScope.launch {
            val systemInstruction = """
                你是一个AI实验室的智能客服专家，专门负责解答用户关于人工智能、生成式AI、图像修图、深度仿冒、AI扩图、风格迁移等技术问题的疑惑。
                你的回答应该专业、亲切、简单易懂，并且通俗化，避免过多的英文技术名词，必须用中文回答。
                回答内容简明扼要，控制在150字以内。
            """.trimIndent()

            val answer = GeminiClient.generate(question, systemInstruction)
            if (answer == "ApiKeyError") {
                _helpAnswer.value = "抱歉，由于缺少您的 API Key，请先到「我的 - API设置」中配置您的 GEMINI_API_KEY 才能获取AI实时解答。"
            } else {
                _helpAnswer.value = answer
            }
            _helpLoading.value = false
        }
    }

    private fun selectCuratedImage(prompt: String, tool: String): String {
        val p = prompt.lowercase()
        return when {
            p.contains("森林") || p.contains("树") || p.contains("精灵") || p.contains("forest") || p.contains("green") -> {
                "https://images.unsplash.com/photo-1502082553048-f009c37129b9?q=80&w=600"
            }
            p.contains("城市") || p.contains("赛博") || p.contains("霓虹") || p.contains("科幻") || p.contains("cyber") || p.contains("city") -> {
                "https://images.unsplash.com/photo-1549611016-3a70d82b5040?q=80&w=600"
            }
            p.contains("油画") || p.contains("复古") || p.contains("古典") || p.contains("巴洛克") || p.contains("vintage") || p.contains("paint") -> {
                "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?q=80&w=600"
            }
            p.contains("动漫") || p.contains("卡通") || p.contains("黏土") || p.contains("萌") || p.contains("avatar") || p.contains("cartoon") -> {
                "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=600"
            }
            p.contains("极光") || p.contains("星空") || p.contains("极夜") || p.contains("aurora") || p.contains("sky") -> {
                "https://images.unsplash.com/photo-1483168527879-c66136b56105?q=80&w=600"
            }
            p.contains("抽象") || p.contains("泼墨") || p.contains("色彩") || p.contains("abstract") -> {
                "https://images.unsplash.com/photo-1541701494587-cb58502866ab?q=80&w=600"
            }
            else -> {
                // Fallback depending on selected tool
                when (tool) {
                    "风格迁移" -> "https://images.unsplash.com/photo-1541701494587-cb58502866ab?q=80&w=600"
                    "换脸" -> "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=600"
                    "AI 扩图" -> "https://images.unsplash.com/photo-1515621061946-eff1c2a352bd?q=80&w=600"
                    "物体移除" -> "https://images.unsplash.com/photo-1483168527879-c66136b56105?q=80&w=600"
                    else -> "https://images.unsplash.com/photo-1549611016-3a70d82b5040?q=80&w=600"
                }
            }
        }
    }
}
