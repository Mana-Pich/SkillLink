<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

#[Fillable([
    'name',
    'email',
    'password',
    'role',
    'profile_image',
])]
#[Hidden([
    'password',
    'remember_token',
])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable;

    /**
     * Services provided by this user.
     */
    public function services(): HasMany
    {
        return $this->hasMany(
            Service::class,
            'provider_id'
        );
    }

    /**
     * Bookings made by this user.
     */
    public function bookings(): HasMany
    {
        return $this->hasMany(
            Booking::class
        );
    }

    /**
     * SkillLink Wallet.
     */
    public function wallet(): HasOne
    {
        return $this->hasOne(
            Wallet::class
        );
    }

    /**
     * Get the attributes that should be cast.
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
}