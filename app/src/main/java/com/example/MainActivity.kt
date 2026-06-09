package com.example

import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.animation.*
import androidx.compose.animation.core.spring
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import coil.compose.AsyncImage
import com.example.data.Masterpiece
import com.example.ui.EditUiState
import com.example.ui.MainViewModel
import com.example.ui.theme.MyApplicationTheme

class MainActivity : ComponentActivity() {
    private val viewModel: MainViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                MainAppScreen(viewModel = viewModel)
            }
        }
    }
}

@Composable
fun MainAppScreen(viewModel: MainViewModel) {
    val activeTab by viewModel.activeTab.collectAsStateWithLifecycle()
    val context = LocalContext.current

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            CustomBottomNavigationBar(
                activeTab = activeTab,
                onTabSelected = { tab -> viewModel.setTab(tab) }
            )
        }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFFF7F8FA)) // Clean light pale background matching screenshot
                .padding(innerPadding)
        ) {
            AnimatedContent(
                targetState = activeTab,
                transitionSpec = {
                    fadeIn(animationSpec = spring()) togetherWith fadeOut(animationSpec = spring())
                },
                label = "TabContentTransition"
            ) { tab ->
                when (tab) {
                    "discover" -> DiscoverTab(viewModel = viewModel)
                    "create" -> CreateTab(viewModel = viewModel)
                    "gallery" -> GalleryTab(viewModel = viewModel)
                    "profile" -> ProfileTab(viewModel = viewModel)
                }
            }

            // Global Masterpiece Detail Sheets / Dialog
            val selectedItem by viewModel.selectedMasterpiece.collectAsStateWithLifecycle()
            selectedItem?.let { item ->
                MasterpieceDetailDialog(
                    item = item,
                    onDismiss = { viewModel.selectMasterpiece(null) },
                    onDelete = {
                        viewModel.deleteMasterpiece(item.id)
                        Toast.makeText(context, "作品已删除", Toast.LENGTH_SHORT).show()
                    }
                )
            }

            // Global Creation Flow Overlay Loading Dialog
            val editUiState by viewModel.editUiState.collectAsStateWithLifecycle()
            if (editUiState is EditUiState.Loading) {
                CreationLoadingOverlay()
            }

            // Global Creation Success/Result Dialog (with Gemini description!)
            if (editUiState is EditUiState.Success) {
                val successState = editUiState as EditUiState.Success
                CreationSuccessDialog(
                    masterpiece = successState.masterpiece,
                    commentary = successState.feedback,
                    onDismiss = { viewModel.clearEditState() }
                )
            }

            // Global Failure / Error message
            if (editUiState is EditUiState.Error) {
                val errorState = editUiState as EditUiState.Error
                AlertDialog(
                    onDismissRequest = { viewModel.clearEditState() },
                    confirmButton = {
                        TextButton(onClick = { viewModel.clearEditState() }) {
                            Text("确定", color = Color(0xFF1E2022))
                        }
                    },
                    title = { Text("创作反馈", fontWeight = FontWeight.Bold) },
                    text = { Text(errorState.message) },
                    shape = RoundedCornerShape(16.dp),
                    containerColor = Color.White
                )
            }
        }
    }
}

// --- Navigation Composable ---

@Composable
fun CustomBottomNavigationBar(
    activeTab: String,
    onTabSelected: (String) -> Unit
) {
    // Elegant light navigation bar, respects navigationBars insets explicitly for edge-to-edge safety
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .windowInsetsPadding(WindowInsets.navigationBars),
        color = Color.White,
        tonalElevation = 6.dp
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(64.dp)
                .padding(horizontal = 8.dp),
            horizontalArrangement = Arrangement.SpaceAround,
            verticalAlignment = Alignment.CenterVertically
        ) {
            val tabs = listOf(
                NavigationTabItem("discover", "发现", Icons.Outlined.Explore, Icons.Filled.Explore, "nav_discover"),
                NavigationTabItem("create", "创作", Icons.Outlined.Brush, Icons.Filled.Brush, "nav_create"),
                NavigationTabItem("gallery", "画廊", Icons.Outlined.PhotoLibrary, Icons.Filled.PhotoLibrary, "nav_gallery"),
                NavigationTabItem("profile", "我的", Icons.Outlined.Person, Icons.Filled.Person, "nav_profile")
            )

            tabs.forEach { item ->
                val isSelected = activeTab == item.id
                Column(
                    modifier = Modifier
                        .weight(1f)
                        .clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null, // Custom clean feel
                            onClick = { onTabSelected(item.id) }
                        )
                        .testTag(item.testTag)
                        .padding(vertical = 4.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Icon(
                        imageVector = if (isSelected) item.activeIcon else item.inactiveIcon,
                        contentDescription = item.label,
                        tint = if (isSelected) Color(0xFF1E2022) else Color(0xFF8E959E),
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = item.label,
                        fontSize = 11.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                        color = if (isSelected) Color(0xFF1E2022) else Color(0xFF8E959E)
                    )
                    // Custom active pill dot indicator
                    if (isSelected) {
                        Box(
                            modifier = Modifier
                                .padding(top = 2.dp)
                                .size(4.dp)
                                .clip(CircleShape)
                                .background(Color(0xFF3B82F6)) // Dynamic subtle blue indicator
                        )
                    } else {
                        Spacer(modifier = Modifier.height(6.dp))
                    }
                }
            }
        }
    }
}

data class NavigationTabItem(
    val id: String,
    val label: String,
    val inactiveIcon: androidx.compose.ui.graphics.vector.ImageVector,
    val activeIcon: androidx.compose.ui.graphics.vector.ImageVector,
    val testTag: String
)

// --- TAB 1: DISCOVER (COMMUNITY) ---

@Composable
fun DiscoverTab(viewModel: MainViewModel) {
    val publicItems by viewModel.publicMasterpieces.collectAsStateWithLifecycle()
    val context = LocalContext.current

    val trendingTags = listOf("赛博朋克日落", "极光山脉", "未来主义城市", "抽象人像", "深海探险", "古风墨韵", "废土美学")

    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
    ) {
        // Thin elegant heading
        Text(
            text = "社区发现",
            fontSize = 32.sp,
            fontWeight = FontWeight.Light,
            color = Color(0xFF1E2022),
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp)
        )

        // Trending Prompts horizontal tags
        Column(modifier = Modifier.padding(bottom = 8.dp)) {
            Text(
                text = "Trending Prompts",
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = Color(0xFF4A5568),
                modifier = Modifier.padding(horizontal = 20.dp, vertical = 4.dp)
            )
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .horizontalScroll(rememberScrollState())
                    .padding(horizontal = 16.dp, vertical = 6.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                trendingTags.forEach { tag ->
                    AssistChip(
                        onClick = {
                            viewModel.setPrompt(tag)
                            viewModel.setTab("create")
                            Toast.makeText(context, "已载入提示词 \"$tag\"", Toast.LENGTH_SHORT).show()
                        },
                        label = { Text(tag, fontSize = 12.sp, fontWeight = FontWeight.Medium) },
                        colors = AssistChipDefaults.assistChipColors(
                            containerColor = Color.White,
                            labelColor = Color(0xFF4A5568)
                        ),
                        border = AssistChipDefaults.assistChipBorder(enabled = true, borderColor = Color(0xFFE2E8F0)),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.testTag("tag_$tag")
                    )
                }
            }
        }

        // Community feed
        if (publicItems.isEmpty()) {
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(
                        imageVector = Icons.Default.CloudQueue,
                        contentDescription = "暂无数据",
                        tint = Color.Gray,
                        modifier = Modifier.size(48.dp)
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text("暂无社区动态", color = Color.Gray)
                }
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(20.dp)
            ) {
                items(publicItems) { item ->
                    CommunityArtworkCard(
                        item = item,
                        onUsePrompt = {
                            viewModel.setPrompt(item.prompt)
                            viewModel.setTool(item.toolType)
                            viewModel.setTab("create")
                            Toast.makeText(context, "已复制提示词并进入创作", Toast.LENGTH_SHORT).show()
                        },
                        onViewDetail = {
                            viewModel.selectMasterpiece(item)
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun CommunityArtworkCard(
    item: Masterpiece,
    onUsePrompt: () -> Unit,
    onViewDetail: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onViewDetail() },
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column {
            // Main image
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(220.dp)
            ) {
                AsyncImage(
                    model = item.imageUrl,
                    contentDescription = item.title,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
                // Tool badge overlay
                Box(
                    modifier = Modifier
                        .padding(12.dp)
                        .align(Alignment.TopEnd)
                        .clip(RoundedCornerShape(8.dp))
                        .background(Color.Black.copy(alpha = 0.6f))
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                ) {
                    Text(
                        text = item.toolType,
                        fontSize = 11.sp,
                        color = Color.White,
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            // User Info & action button
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(
                                Brush.radialGradient(
                                    colors = listOf(Color(0xFFE0F2FE), Color(0xFFBAE6FD))
                                )
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Person,
                            contentDescription = "用户头像",
                            tint = Color(0xFF0284C7),
                            modifier = Modifier.size(20.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(10.dp))
                    Column {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = item.authorName,
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFF1E2022)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Icon(
                                imageVector = Icons.Default.Verified,
                                contentDescription = "认证认证",
                                tint = Color(0xFF3B82F6),
                                modifier = Modifier.size(14.dp)
                            )
                        }
                        Text(
                            text = item.title,
                            fontSize = 12.sp,
                            color = Color.Gray,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.width(150.dp)
                        )
                    }
                }

                Button(
                    onClick = onUsePrompt,
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color(0xFFF1F5F9),
                        contentColor = Color(0xFF334155)
                    ),
                    contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp),
                    modifier = Modifier
                        .height(36.dp)
                        .testTag("use_prompt_btn_${item.id}")
                ) {
                    Icon(
                        imageVector = Icons.Default.Add,
                        contentDescription = "使用提示词",
                        modifier = Modifier.size(14.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("使用此提示词", fontSize = 12.sp, fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}

// --- TAB 2: CREATE (AI LAB EDITING DESIGN) ---

@Composable
fun CreateTab(viewModel: MainViewModel) {
    val prompt by viewModel.prompt.collectAsStateWithLifecycle()
    val isPrivate by viewModel.isPrivate.collectAsStateWithLifecycle()
    val selectedTool by viewModel.selectedTool.collectAsStateWithLifecycle()

    val tools = listOf(
        ToolItem("风格迁移", Icons.Default.Brush, "style_transfer_card"),
        ToolItem("换脸", Icons.Default.Face, "face_swap_card"),
        ToolItem("AI 扩图", Icons.Default.AspectRatio, "outpainting_card"),
        ToolItem("物体移除", Icons.Default.ContentCut, "object_removal_card")
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
            .verticalScroll(rememberScrollState())
    ) {
        // Section Header: AI 实验室 极简版 (淡色)
        Text(
            text = "AI 实验室 极简版 (淡色)",
            fontSize = 30.sp,
            fontWeight = FontWeight.Bold,
            color = Color(0xFF1E2022),
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp),
            textAlign = TextAlign.Center
        )

        // Main creative center artwork banner
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .height(240.dp)
                .padding(horizontal = 20.dp),
            shape = RoundedCornerShape(24.dp),
            elevation = CardDefaults.cardElevation(defaultElevation = 0.dp)
        ) {
            Box(modifier = Modifier.fillMaxSize()) {
                // Creative dynamic backdrop girl
                AsyncImage(
                    model = when (selectedTool) {
                        "风格迁移" -> "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=600"
                        "换脸" -> "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=600"
                        "AI 扩图" -> "https://images.unsplash.com/photo-1511556532299-8f662fc26c06?q=80&w=600"
                        else -> "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600"
                    },
                    contentDescription = "主视觉图",
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
                // Floating subtle status tag
                Box(
                    modifier = Modifier
                        .padding(16.dp)
                        .align(Alignment.BottomStart)
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color.Black.copy(alpha = 0.5f))
                        .padding(horizontal = 12.dp, vertical = 6.dp)
                ) {
                    Text(
                        text = "正在编辑：${selectedTool}",
                        color = Color.White,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Middle Section Title: 智能修改
        Text(
            text = "智能修改",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = Color(0xFF1E2022),
            modifier = Modifier.padding(horizontal = 24.dp, vertical = 6.dp)
        )

        // 2x2 Operations grid
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            val rows = tools.chunked(2)
            rows.forEach { rowItems ->
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    rowItems.forEach { tool ->
                        val isSelected = selectedTool == tool.name
                        Card(
                            modifier = Modifier
                                .weight(1f)
                                .height(80.dp)
                                .clickable { viewModel.setTool(tool.name) }
                                .testTag(tool.testTag),
                            shape = RoundedCornerShape(16.dp),
                            colors = CardDefaults.cardColors(
                                containerColor = if (isSelected) Color(0xFFEFF6FF) else Color(0xFFF1F5F9)
                            ),
                            border = if (isSelected) BorderStroke(1.5.dp, Color(0xFF3B82F6)) else null
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .padding(horizontal = 16.dp),
                                horizontalArrangement = Arrangement.Start,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = tool.icon,
                                    contentDescription = tool.name,
                                    tint = if (isSelected) Color(0xFF3B82F6) else Color(0xFF64748B),
                                    modifier = Modifier.size(28.dp)
                                )
                                Spacer(modifier = Modifier.width(10.dp))
                                Text(
                                    text = tool.name,
                                    fontSize = 15.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = if (isSelected) Color(0xFF1E3A8A) else Color(0xFF334155)
                                )
                            }
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Bottom Prompts layout with active "公开 / 私密" properties
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp),
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "创作配置与范围",
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF475569)
                    )
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = if (isPrivate) "私密保存" else "公开同步 (社区)",
                            fontSize = 12.sp,
                            color = Color(0xFF64748B),
                            modifier = Modifier.padding(end = 6.dp)
                        )
                        Switch(
                            checked = isPrivate,
                            onCheckedChange = { viewModel.setPrivate(it) },
                            colors = SwitchDefaults.colors(
                                checkedThumbColor = Color.White,
                                checkedTrackColor = Color(0xFF3B82F6)
                            ),
                            modifier = Modifier
                                .scale(0.8f)
                                .testTag("private_sync_switch")
                        )
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))

                // Prompt Input Box
                TextField(
                    value = prompt,
                    onValueChange = { viewModel.setPrompt(it) },
                    placeholder = { Text("输入提示词，AI 助你创作...", color = Color(0xFF94A3B8)) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(86.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .testTag("prompt_input_field"),
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = Color(0xFFF8FAFC),
                        unfocusedContainerColor = Color(0xFFF8FAFC),
                        focusedIndicatorColor = Color.Transparent,
                        unfocusedIndicatorColor = Color.Transparent,
                        disabledIndicatorColor = Color.Transparent
                    ),
                    keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
                    keyboardActions = KeyboardActions(onDone = { viewModel.performAiEdit() })
                )

                Spacer(modifier = Modifier.height(12.dp))

                // Action Pill Button "AI 修图"
                Button(
                    onClick = { viewModel.performAiEdit() },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp)
                        .testTag("process_ai_btn"),
                    shape = RoundedCornerShape(24.dp),
                    colors = ButtonColors(
                        containerColor = Color(0xFF1E2022), // Masterful dark accent
                        contentColor = Color.White,
                        disabledContainerColor = Color.LightGray,
                        disabledContentColor = Color.White
                    )
                ) {
                    Icon(
                        imageVector = Icons.Default.AutoAwesome,
                        contentDescription = "AI 修图",
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("AI 修图", fontSize = 15.sp, fontWeight = FontWeight.Bold)
                }
            }
        }

        Spacer(modifier = Modifier.height(40.dp))
    }
}

data class ToolItem(val name: String, val icon: androidx.compose.ui.graphics.vector.ImageVector, val testTag: String)

// --- TAB 3: GALLERY (WORK GALLERY) ---

@Composable
fun GalleryTab(viewModel: MainViewModel) {
    val masterpieces by viewModel.allMasterpieces.collectAsStateWithLifecycle()
    var showOnlyPublic by remember { mutableStateOf(false) }

    val filteredList = if (showOnlyPublic) {
        masterpieces.filter { !it.isPrivate }
    } else {
        masterpieces
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
    ) {
        // Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "作品图库 极简版",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = Color(0xFF1E2022)
            )

            // Split toggler with nice label
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = if (showOnlyPublic) "公开" else "全部",
                    fontSize = 13.sp,
                    color = Color(0xFF64748B),
                    fontWeight = FontWeight.Medium
                )
                Spacer(modifier = Modifier.width(6.dp))
                Switch(
                    checked = showOnlyPublic,
                    onCheckedChange = { showOnlyPublic = it },
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = Color.White,
                        checkedTrackColor = Color(0xFF3B82F6)
                    ),
                    modifier = Modifier
                        .scale(0.82f)
                        .testTag("gallery_filter_switch")
                )
            }
        }

        if (filteredList.isEmpty()) {
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(
                        imageVector = Icons.Default.PhotoLibrary,
                        contentDescription = "暂无作品",
                        tint = Color.LightGray,
                        modifier = Modifier.size(64.dp)
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                    Text("图库暂无作品，快去'创作'制作一个吧！", color = Color.Gray, fontSize = 14.sp)
                }
            }
        } else {
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                contentPadding = PaddingValues(16.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
            ) {
                items(filteredList) { item ->
                    GalleryMasterpieceCard(
                        item = item,
                        onClick = { viewModel.selectMasterpiece(item) }
                    )
                }
            }
        }
    }
}

@Composable
fun GalleryMasterpieceCard(
    item: Masterpiece,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .testTag("gallery_card_${item.id}"),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Column {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(140.dp)
            ) {
                AsyncImage(
                    model = item.imageUrl,
                    contentDescription = item.title,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
                // Private/Public subtle lock indicator badge
                Box(
                    modifier = Modifier
                        .padding(8.dp)
                        .align(Alignment.TopStart)
                        .clip(CircleShape)
                        .background(Color.Black.copy(alpha = 0.5f))
                        .padding(4.dp)
                ) {
                    Icon(
                        imageVector = if (item.isPrivate) Icons.Default.Lock else Icons.Default.Public,
                        contentDescription = if (item.isPrivate) "私密" else "公开",
                        tint = Color.White,
                        modifier = Modifier.size(12.dp)
                    )
                }
            }
            Column(modifier = Modifier.padding(10.dp)) {
                Text(
                    text = item.title,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF1E2022),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = item.toolType,
                    fontSize = 11.sp,
                    color = Color(0xFF3B82F6),
                    fontWeight = FontWeight.SemiBold
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = item.prompt,
                    fontSize = 11.sp,
                    color = Color.Gray,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}

// --- TAB 4: PROFILE & INTERACTIVE HELPER (Q&A DESK) ---

@Composable
fun ProfileTab(viewModel: MainViewModel) {
    val masterpieces by viewModel.allMasterpieces.collectAsStateWithLifecycle()
    var showApiDialog by remember { mutableStateOf(false) }
    var showAccountDialog by remember { mutableStateOf(false) }
    var showAboutDialog by remember { mutableStateOf(false) }
    var showHelpDeskDialog by remember { mutableStateOf(false) }

    val creationCount = masterpieces.size

    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
            .verticalScroll(rememberScrollState())
    ) {
        // Center Page Title
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp)
        ) {
            Text(
                text = "个人中心",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = Color(0xFF1E2022),
                modifier = Modifier.align(Alignment.Center)
            )
            IconButton(
                onClick = { showAccountDialog = true },
                modifier = Modifier.align(Alignment.CenterEnd)
            ) {
                Icon(
                    imageVector = Icons.Default.Edit,
                    contentDescription = "修改资料",
                    tint = Color(0xFF555555)
                )
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        // Avatar Circular Card
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .size(90.dp)
                    .clip(CircleShape)
                    .border(3.dp, Color.White, CircleShape)
                    .background(
                        Brush.radialGradient(
                            colors = listOf(Color(0xFFE0E7FF), Color(0xFFC7D2FE))
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.AccountCircle,
                    contentDescription = "AI头像",
                    tint = Color(0xFF4F46E5),
                    modifier = Modifier.size(70.dp)
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = "AI_Designer_01",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF1E2022)
                )
                Spacer(modifier = Modifier.width(4.dp))
                Icon(
                    imageVector = Icons.Default.Verified,
                    contentDescription = "已认证",
                    tint = Color(0xFF2563EB),
                    modifier = Modifier.size(16.dp)
                )
            }
            Text(
                text = "系统默认AI智能设计师",
                fontSize = 12.sp,
                color = Color.Gray,
                modifier = Modifier.padding(top = 4.dp)
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Stats Box
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp),
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 16.dp),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "$creationCount",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF1E2022)
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(text = "编辑", fontSize = 12.sp, color = Color.Gray)
                }
                Box(
                    modifier = Modifier
                        .height(24.dp)
                        .width(1.dp)
                        .background(Color(0xFFE2E8F0))
                )
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "89.2k",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF1E2022)
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(text = "喜欢", fontSize = 12.sp, color = Color.Gray)
                }
                Box(
                    modifier = Modifier
                        .height(24.dp)
                        .width(1.dp)
                        .background(Color(0xFFE2E8F0))
                )
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "540",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF1E2022)
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(text = "关注", fontSize = 12.sp, color = Color.Gray)
                }
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // 2x2 Grid menu
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            val menuItems = listOf(
                ProfileMenuItem("API设置", Icons.Default.Settings, "btn_api_settings") { showApiDialog = true },
                ProfileMenuItem("账号管理", Icons.Default.ManageAccounts, "btn_account_mgmt") { showAccountDialog = true },
                ProfileMenuItem("关于", Icons.Default.Info, "btn_about") { showAboutDialog = true },
                ProfileMenuItem("帮助中心", Icons.Default.HelpCenter, "btn_help_desk") { showHelpDeskDialog = true }
            )

            val rows = menuItems.chunked(2)
            rows.forEach { rowItems ->
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    rowItems.forEach { item ->
                        Card(
                            modifier = Modifier
                                .weight(1f)
                                .height(94.dp)
                                .clickable { item.onClick() }
                                .testTag(item.testTag),
                            shape = RoundedCornerShape(16.dp),
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
                        ) {
                            Column(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .padding(16.dp),
                                horizontalAlignment = Alignment.CenterHorizontally,
                                verticalArrangement = Arrangement.Center
                            ) {
                                Icon(
                                    imageVector = item.icon,
                                    contentDescription = item.title,
                                    tint = Color(0xFF555555),
                                    modifier = Modifier.size(24.dp)
                                )
                                Spacer(modifier = Modifier.height(8.dp))
                                Text(
                                    text = item.title,
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    color = Color(0xFF334155)
                                )
                            }
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(40.dp))
    }

    // --- DIALOGS FOR PROFILE ---

    if (showApiDialog) {
        ApiSettingsDialog(onDismiss = { showApiDialog = false })
    }

    if (showAccountDialog) {
        AccountMgmtDialog(onDismiss = { showAccountDialog = false })
    }

    if (showAboutDialog) {
        AboutDialog(onDismiss = { showAboutDialog = false })
    }

    if (showHelpDeskDialog) {
        HelpDeskQADialog(viewModel = viewModel, onDismiss = { showHelpDeskDialog = false })
    }
}

data class ProfileMenuItem(
    val title: String,
    val icon: androidx.compose.ui.graphics.vector.ImageVector,
    val testTag: String,
    val onClick: () -> Unit
)

// --- SUB-DIALOG COMPONENTS ---

@Composable
fun ApiSettingsDialog(onDismiss: () -> Unit) {
    AlertDialog(
        onDismissRequest = onDismiss,
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("关闭", color = Color(0xFF3B82F6))
            }
        },
        title = { Text("API 密钥设置", fontWeight = FontWeight.Bold) },
        text = {
            Column {
                Text(
                    text = "系统采用安全管理。密钥通过后台 .env 文件安全注入为 BuildConfig.GEMINI_API_KEY，无需在客户端明文硬编码保护数据隐私。",
                    fontSize = 14.sp,
                    color = Color(0xFF475569)
                )
                Spacer(modifier = Modifier.height(10.dp))
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(8.dp))
                        .background(Color(0xFFF1F5F9))
                        .padding(12.dp)
                ) {
                    Text(
                        text = "当前配置状态: 已激活 (Inject System Key)",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF0F766E)
                    )
                }
            }
        },
        shape = RoundedCornerShape(16.dp),
        containerColor = Color.White
    )
}

@Composable
fun AccountMgmtDialog(onDismiss: () -> Unit) {
    AlertDialog(
        onDismissRequest = onDismiss,
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("确定", color = Color(0xFF3B82F6))
            }
        },
        title = { Text("账号管理", fontWeight = FontWeight.Bold) },
        text = {
            Column {
                Text("用户名: AI_Designer_01", fontWeight = FontWeight.SemiBold)
                Text("用户类型: 开发者测试账号")
                Text("创作点数: ♾️ 无限能量")
                Spacer(modifier = Modifier.height(6.dp))
                Text("系统已在AI Studio沙盒中保持自动同步。", fontSize = 12.sp, color = Color.Gray)
            }
        },
        shape = RoundedCornerShape(16.dp),
        containerColor = Color.White
    )
}

@Composable
fun AboutDialog(onDismiss: () -> Unit) {
    AlertDialog(
        onDismissRequest = onDismiss,
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("好", color = Color(0xFF3B82F6))
            }
        },
        title = { Text("关于 AI 实验室", fontWeight = FontWeight.Bold) },
        text = {
            Column {
                Text("AI 实验室 极简版 (淡色) v1.0", fontWeight = FontWeight.Bold, fontSize = 15.sp)
                Spacer(modifier = Modifier.height(4.dp))
                Text("基于 Google AI Studio 平台开发，由先进的 Gemini 3.5 Flash 智能大模型驱动。让每个人都能轻松享受智能照片修改、图像风格艺术分析与生成的乐趣。")
            }
        },
        shape = RoundedCornerShape(16.dp),
        containerColor = Color.White
    )
}

@Composable
fun HelpDeskQADialog(viewModel: MainViewModel, onDismiss: () -> Unit) {
    var customQuestion by remember { mutableStateOf("") }
    val answer by viewModel.helpAnswer.collectAsStateWithLifecycle()
    val loading by viewModel.helpLoading.collectAsStateWithLifecycle()

    val quickQuestions = listOf(
        "什么是AI扩图？",
        "为什么生成图像有时手部不自然？",
        "什么是风格迁移技术？"
    )

    Dialog(onDismissRequest = onDismiss) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.85f),
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(20.dp)
            ) {
                // Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("智能帮助台", fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    IconButton(onClick = onDismiss) {
                        Icon(imageVector = Icons.Default.Close, contentDescription = "关闭")
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                // Scrollable workspace QA
                Column(
                    modifier = Modifier
                        .weight(1f)
                        .verticalScroll(rememberScrollState())
                ) {
                    Text("热门问题快速解答：", fontSize = 13.sp, color = Color.Gray, fontWeight = FontWeight.Bold)
                    Spacer(modifier = Modifier.height(6.dp))

                    quickQuestions.forEach { q ->
                        OutlinedButton(
                            onClick = {
                                customQuestion = q
                                viewModel.askHelpQuestion(q)
                            },
                            shape = RoundedCornerShape(12.dp),
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp),
                            contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
                        ) {
                            Text(q, fontSize = 12.sp, color = Color(0xFF475569), textAlign = TextAlign.Start)
                        }
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Answer Box
                    if (answer.isNotEmpty() || loading) {
                        Text("AI 助理解答：", fontSize = 13.sp, color = Color.Gray, fontWeight = FontWeight.Bold)
                        Spacer(modifier = Modifier.height(6.dp))
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(12.dp))
                                .background(Color(0xFFF8FAFC))
                                .border(1.dp, Color(0xFFE2E8F0), RoundedCornerShape(12.dp))
                                .padding(12.dp)
                        ) {
                            if (loading) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    CircularProgressIndicator(modifier = Modifier.size(16.dp), strokeWidth = 2.dp)
                                    Spacer(modifier = Modifier.width(10.dp))
                                    Text("思考回答中...", fontSize = 13.sp, color = Color.Gray)
                                }
                            } else {
                                Text(answer, fontSize = 13.sp, color = Color(0xFF334155))
                            }
                        }
                    }
                }

                // Custom Question Input row
                Column(modifier = Modifier.padding(top = 10.dp)) {
                    TextField(
                        value = customQuestion,
                        onValueChange = { customQuestion = it },
                        placeholder = { Text("输入自定义AI技术问题...", fontSize = 13.sp) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp)),
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = Color(0xFFF1F5F9),
                            unfocusedContainerColor = Color(0xFFF1F5F9),
                            focusedIndicatorColor = Color.Transparent,
                            unfocusedIndicatorColor = Color.Transparent
                        )
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Button(
                        onClick = {
                            if (customQuestion.trim().isNotEmpty()) {
                                viewModel.askHelpQuestion(customQuestion)
                            }
                        },
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF1E2022))
                    ) {
                        Text("向AI提问", fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}

// --- MASTERPIECE DETAIL FULL MODEL DIALOG ---

@Composable
fun MasterpieceDetailDialog(
    item: Masterpiece,
    onDismiss: () -> Unit,
    onDelete: () -> Unit
) {
    Dialog(onDismissRequest = onDismiss) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.88f),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
            ) {
                // Top Close bar
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = if (item.isPrivate) Icons.Default.Lock else Icons.Default.Public,
                            contentDescription = "可见性",
                            tint = Color.Gray,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = if (item.isPrivate) "私密保存" else "公开作品",
                            fontSize = 12.sp,
                            color = Color.Gray,
                            fontWeight = FontWeight.Medium
                        )
                    }
                    IconButton(onClick = onDismiss) {
                        Icon(imageVector = Icons.Default.Close, contentDescription = "关闭")
                    }
                }

                // Main Image
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(280.dp)
                        .padding(horizontal = 20.dp)
                        .clip(RoundedCornerShape(20.dp))
                ) {
                    AsyncImage(
                        model = item.imageUrl,
                        contentDescription = item.title,
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                    Box(
                        modifier = Modifier
                            .padding(12.dp)
                            .align(Alignment.BottomEnd)
                            .clip(RoundedCornerShape(8.dp))
                            .background(Color.Black.copy(alpha = 0.6f))
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text(
                            text = item.toolType,
                            color = Color.White,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }

                // Explanations
                Column(modifier = Modifier.padding(20.dp)) {
                    Text(
                        text = item.title,
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF1E2022)
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "作者: ${item.authorName}",
                        fontSize = 13.sp,
                        color = Color.Gray
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    Text(
                        text = "创作提示词：",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF475569)
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(Color(0xFFF1F5F9))
                            .padding(12.dp)
                    ) {
                        Text(
                            text = item.prompt,
                            fontSize = 13.sp,
                            color = Color(0xFF334155),
                            fontWeight = FontWeight.Medium
                        )
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Simulated AI commentary (Since we stored initial presets too we offer high quality fallback or they can ask AI again)
                    Text(
                        text = "AI 艺术评析（大师视界）：",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF475569)
                    )
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = "通过【${item.toolType}】的奇妙作用，提示词「${item.prompt}」展现出了不可思议的张力。画面色彩运用大胆，整体色调具有高级数码材质的渲染细节，明暗线条流畅，呈现出一个精美而虚幻的独立艺术世界，将科技与艺术的情感完美交融。",
                        fontSize = 13.sp,
                        color = Color(0xFF334155),
                        lineHeight = 18.sp
                    )

                    Spacer(modifier = Modifier.height(24.dp))

                    // Delete button option for custom owned assets
                    if (item.authorName == "AI_Designer_01") {
                        Button(
                            onClick = onDelete,
                            modifier = Modifier.fillMaxWidth(),
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFECACA), contentColor = Color(0xFFDC2626)),
                            shape = RoundedCornerShape(14.dp)
                        ) {
                            Icon(imageVector = Icons.Default.Delete, contentDescription = "删除作品", modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            Text("从图库彻底删除作品", fontSize = 13.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }
            }
        }
    }
}

// --- OVERLAY LOADING BLOCK ---

@Composable
fun CreationLoadingOverlay() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.45f))
            .clickable(enabled = false) {}, // Eat touch event
        contentAlignment = Alignment.Center
    ) {
        Card(
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp),
            modifier = Modifier.width(180.dp)
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                CircularProgressIndicator(
                    color = Color(0xFF1E2022),
                    strokeWidth = 3.dp,
                    modifier = Modifier.size(40.dp)
                )
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = "AI 正在创作灵感...",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF1E2022)
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "极速生成中...",
                    fontSize = 11.sp,
                    color = Color.Gray
                )
            }
        }
    }
}

// --- CREATION SUCCESS DIALOG WITH GERMINI ANALYSIS ---

@Composable
fun CreationSuccessDialog(
    masterpiece: Masterpiece,
    commentary: String,
    onDismiss: () -> Unit
) {
    Dialog(onDismissRequest = onDismiss) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.85f),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(20.dp)
                    .verticalScroll(rememberScrollState()),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Celebration Title
                Icon(
                    imageVector = Icons.Default.AutoAwesome,
                    contentDescription = "Success",
                    tint = Color(0xFFEAB308),
                    modifier = Modifier.size(36.dp)
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "智能修图成功！",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF15803D)
                )
                Text(
                    text = "作品已自动归档至【作品图库】",
                    fontSize = 11.sp,
                    color = Color.Gray,
                    modifier = Modifier.padding(top = 2.dp)
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Generated Image view
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(200.dp)
                        .clip(RoundedCornerShape(16.dp))
                ) {
                    AsyncImage(
                        model = masterpiece.imageUrl,
                        contentDescription = masterpiece.title,
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                    Box(
                        modifier = Modifier
                            .padding(8.dp)
                            .align(Alignment.BottomStart)
                            .clip(RoundedCornerShape(6.dp))
                            .background(Color.Black.copy(alpha = 0.6f))
                            .padding(horizontal = 8.dp, vertical = 2.dp)
                    ) {
                        Text(
                            text = masterpiece.toolType,
                            color = Color.White,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Gemini real time custom description review
                Text(
                    text = "Gemini AI 艺术赏析描述：",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF475569),
                    modifier = Modifier.align(Alignment.Start)
                )
                Spacer(modifier = Modifier.height(6.dp))
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color(0xFFF1F5F9))
                        .padding(12.dp)
                ) {
                    Text(
                        text = commentary,
                        fontSize = 13.sp,
                        color = Color(0xFF334155),
                        lineHeight = 18.sp
                    )
                }

                Spacer(modifier = Modifier.height(24.dp))

                Button(
                    onClick = onDismiss,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(46.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF1E2022))
                ) {
                    Text("返回并继续创作", fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}
