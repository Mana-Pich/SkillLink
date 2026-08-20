<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wallet_transactions', function (Blueprint $table) {
            $table->id();

            $table->foreignId('wallet_id')
                ->constrained('wallets')
                ->cascadeOnDelete();

            $table->decimal('amount', 12, 2);

            $table->enum('type', [
                'deposit',
                'payment',
                'refund',
            ]);

            $table->enum('status', [
                'pending',
                'completed',
                'failed',
            ])->default('completed');

            $table->string('description')->nullable();

            $table->string('reference')->unique();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallet_transactions');
    }
};