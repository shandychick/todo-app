<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTasksTable extends Migration
{
    public function up()
    {
        Schema::create('tasks', function (Blueprint $table) {
            $table->id('id_tugas');
            $table->string('nama_tugas');
            $table->text('deskripsi')->nullable();
            $table->date('deadline');
            $table->string('status')->default('belum'); // default "belum"
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('tasks');
    }
}
