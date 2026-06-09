package com.example.data

import kotlinx.coroutines.flow.Flow

class MasterpieceRepository(private val masterpieceDao: MasterpieceDao) {
    val allMasterpieces: Flow<List<Masterpiece>> = masterpieceDao.getAllMasterpieces()
    val publicMasterpieces: Flow<List<Masterpiece>> = masterpieceDao.getPublicMasterpieces()

    suspend fun insert(masterpiece: Masterpiece) {
        masterpieceDao.insertMasterpiece(masterpiece)
    }

    suspend fun deleteById(id: Int) {
        masterpieceDao.deleteMasterpieceById(id)
    }

    suspend fun populateInitialDataIfEmpty() {
        if (masterpieceDao.getCount() == 0) {
            val initialList = listOf(
                Masterpiece(
                    title = "梦幻森林",
                    prompt = "梦幻般的精灵森林，晨雾与金色阳光穿过古老树木",
                    toolType = "风格迁移",
                    imageUrl = "https://images.unsplash.com/photo-1502082553048-f009c37129b9?q=80&w=600",
                    isPrivate = false,
                    authorName = "AI_Designer_01"
                ),
                Masterpiece(
                    title = "未来城市",
                    prompt = "赛博朋克风格未来都市，高耸入云的全息霓虹大厦",
                    toolType = "AI 扩图",
                    imageUrl = "https://images.unsplash.com/photo-1549611016-3a70d82b5040?q=80&w=600",
                    isPrivate = false,
                    authorName = "AI_Designer_01"
                ),
                Masterpiece(
                    title = "抽象艺术",
                    prompt = "现代抽象艺术泼墨，缤纷艳丽的色彩斑驳交融",
                    toolType = "风格迁移",
                    imageUrl = "https://images.unsplash.com/photo-1541701494587-cb58502866ab?q=80&w=600",
                    isPrivate = false,
                    authorName = "AI_Designer_01"
                ),
                Masterpiece(
                    title = "卡通肖像",
                    prompt = "卡通黏土风小男孩头像，温暖和善的微笑，亮橘色高领卫衣",
                    toolType = "换脸",
                    imageUrl = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=600",
                    isPrivate = false,
                    authorName = "AI_Designer_01"
                ),
                Masterpiece(
                    title = "复古油画",
                    prompt = "17世纪巴洛克古典仕女肖像，柔和光影，油画质感细腻",
                    toolType = "风格迁移",
                    imageUrl = "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?q=80&w=600",
                    isPrivate = true,
                    authorName = "AI_Designer_01"
                ),
                Masterpiece(
                    title = "极光夜景",
                    prompt = "绿色极光飞舞掠过冬日星空，厚厚雪地上照耀出璀璨光芒",
                    toolType = "物体移除",
                    imageUrl = "https://images.unsplash.com/photo-1483168527879-c66136b56105?q=80&w=600",
                    isPrivate = true,
                    authorName = "AI_Designer_01"
                ),
                Masterpiece(
                    title = "赛博朋克日落",
                    prompt = "赛博朋克日落下的宏伟未来建筑群，飞船在摩天大楼间穿梭",
                    toolType = "AI 扩图",
                    imageUrl = "https://images.unsplash.com/photo-1515621061946-eff1c2a352bd?q=80&w=600",
                    isPrivate = false,
                    authorName = "AI艺术家_李"
                ),
                Masterpiece(
                    title = "极光山脉",
                    prompt = "雄伟雪山在夜幕下矗立，绚烂极光在山顶舞动，倒映在宁静的冰湖中",
                    toolType = "风格迁移",
                    imageUrl = "https://images.unsplash.com/photo-1483168527879-c66136b56105?q=80&w=600",
                    isPrivate = false,
                    authorName = "视觉创造者"
                )
            )

            for (item in initialList) {
                masterpieceDao.insertMasterpiece(item)
            }
        }
    }
}
