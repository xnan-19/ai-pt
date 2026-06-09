package com.example.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface MasterpieceDao {
    @Query("SELECT * FROM masterpieces ORDER BY createdAt DESC")
    fun getAllMasterpieces(): Flow<List<Masterpiece>>

    @Query("SELECT * FROM masterpieces WHERE isPrivate = 0 ORDER BY createdAt DESC")
    fun getPublicMasterpieces(): Flow<List<Masterpiece>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMasterpiece(masterpiece: Masterpiece)

    @Query("DELETE FROM masterpieces WHERE id = :id")
    suspend fun deleteMasterpieceById(id: Int)

    @Query("SELECT COUNT(*) FROM masterpieces")
    suspend fun getCount(): Int
}
