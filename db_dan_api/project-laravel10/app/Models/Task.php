<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    protected $table = 'tasks';
    protected $primaryKey = 'id_tugas';
    protected $fillable = [
        'nama_tugas',
        'deskripsi',
        'deadline',
        'status',
    ];

    protected $casts = [
        'deadline' => 'datetime',
        'status' => 'string', // Bisa diganti enum PHP 8.1 jika mau
    ];
}
