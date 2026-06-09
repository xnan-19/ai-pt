package com.example.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "masterpieces")
data class Masterpiece(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val title: String,
    val prompt: String,
    val toolType: String, // "风格迁移", "换脸", "AI 扩图", "物体移除"
    val imageUrl: String,
    val isPrivate: Boolean = false,
    val authorName: String = "AI_Designer_01",
    val createdAt: Long = System.currentTimeMillis()
)
