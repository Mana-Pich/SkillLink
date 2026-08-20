<?php

use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ServiceController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;

Route::apiResource('categories', CategoryController::class);

Route::apiResource('services', ServiceController::class);

Route::get('users', [UserController::class, 'index']);
Route::post('users', [UserController::class, 'store']);
Route::get('users/{user}', [UserController::class, 'show']);

Route::apiResource('bookings', BookingController::class);

Route::get('payments', [PaymentController::class, 'index']);
Route::post('payments', [PaymentController::class, 'store']);
Route::get('payments/{payment}', [PaymentController::class, 'show']);

Route::post('/register', [
    AuthController::class,
    'register',
]);

Route::post('/login', [
    AuthController::class,
    'login',
]);

Route::get('/users/{user}/wallet', [WalletController::class, 'show']);

Route::get(
    '/users/{userId}/profile',
    [ProfileController::class, 'show']
);

Route::post(
    '/users/{userId}/profile/image',
    [ProfileController::class, 'updateImage']
);

Route::delete(
    '/users/{userId}/profile/image',
    [ProfileController::class, 'deleteImage']
);