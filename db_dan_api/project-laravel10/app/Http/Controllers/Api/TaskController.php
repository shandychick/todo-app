<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Task;

class TaskController extends Controller
{
    public function index()
    {
        return Task::all();
    }

    public function store(Request $request)
{
    $request->validate([
        'nama_tugas' => 'required|string',
        'deskripsi' => 'nullable|string',
        'deadline' => 'required|date',
        'status' => 'required|in:tuntas,belum',
    ]);

    $task = Task::create([
        'nama_tugas' => $request->nama_tugas,
        'deskripsi' => $request->deskripsi,
        'deadline' => $request->deadline,
        'status' => $request->status,
    ]);

    return response()->json($task, 201);
}


    public function update(Request $request, $id)
    {
        $request->validate([
            'nama_tugas' => 'sometimes|required|string',
            'deskripsi' => 'nullable|string',
            'deadline' => 'sometimes|required|date',
            'status' => 'sometimes|required|in:belum,tuntas',
        ]);

        $task = Task::findOrFail($id);
        $task->update($request->only(['nama_tugas', 'deskripsi', 'deadline', 'status']));

        return response()->json($task);
    }

    public function destroy($id)
    {
        Task::destroy($id);
        return response()->json(null, 204);
    }
}
