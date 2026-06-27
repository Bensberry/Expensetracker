'use client';

import { BottomNav } from '@/components/bottom-nav';
import { GlassCard } from '@/components/glass-card';
import { Camera, Upload, ArrowLeft, Plus } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';

export default function AddExpense() {
  const [activeTab, setActiveTab] = useState<'manual' | 'receipt'>('manual');

  const categories = [
    { icon: '☕', label: 'Food', value: 'food' },
    { icon: '🚗', label: 'Transport', value: 'transport' },
    { icon: '🛍️', label: 'Shopping', value: 'shopping' },
    { icon: '🏠', label: 'Utilities', value: 'utilities' },
    { icon: '🎬', label: 'Entertainment', value: 'entertainment' },
  ];

  return (
    <main className="min-h-screen bg-gradient-to-br from-[#050811] via-[#0a0f1f] to-[#050811] grain pb-24 relative overflow-hidden">
      {/* Background glow */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        <div className="absolute top-0 right-0 w-96 h-96 bg-cyan-500/5 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-0 left-0 w-72 h-72 bg-purple-500/5 rounded-full blur-3xl animate-pulse" style={{ animationDelay: '1s' }}></div>
      </div>

      {/* Header */}
      <div className="sticky top-0 z-40 bg-gradient-to-b from-[#050811] via-[#050811]/90 to-[#050811]/50 backdrop-blur-xl border-b border-white/5 p-6 relative">
        <div className="max-w-md mx-auto flex items-center gap-4">
          <Link href="/" className="p-2 rounded-lg hover:bg-white/10 transition-smooth">
            <ArrowLeft size={24} className="text-white" />
          </Link>
          <h1 className="text-2xl font-bold text-white">Add Expense</h1>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-md mx-auto px-6 pt-6 relative z-10">
        {/* Tabs */}
        <div className="flex gap-2 mb-6">
          <button
            onClick={() => setActiveTab('manual')}
            className={`flex-1 py-3 px-4 rounded-xl font-semibold transition-smooth ${
              activeTab === 'manual'
                ? 'bg-gradient-to-r from-cyan-500/40 to-cyan-400/30 border border-cyan-400/50 text-cyan-300 shadow-lg glow-cyan'
                : 'bg-white/5 border border-white/10 text-white/70 hover:text-white'
            }`}
          >
            Manual Entry
          </button>
          <button
            onClick={() => setActiveTab('receipt')}
            className={`flex-1 py-3 px-4 rounded-xl font-semibold transition-smooth ${
              activeTab === 'receipt'
                ? 'bg-gradient-to-r from-cyan-500/40 to-cyan-400/30 border border-cyan-400/50 text-cyan-300 shadow-lg glow-cyan'
                : 'bg-white/5 border border-white/10 text-white/70 hover:text-white'
            }`}
          >
            Scan Receipt
          </button>
        </div>

        {activeTab === 'manual' ? (
          <>
            {/* Amount Input */}
            <GlassCard variant="premium" className="mb-6">
              <label className="text-white/60 text-sm block mb-3 font-medium">Amount</label>
              <div className="relative">
                <span className="absolute left-4 top-4 text-3xl text-cyan-400">$</span>
                <input
                  type="number"
                  placeholder="0.00"
                  className="w-full bg-white/5 border border-white/10 rounded-xl pl-10 pr-4 py-4 text-4xl font-bold text-white placeholder-white/20 focus:outline-none focus:border-cyan-400/50 focus:ring-2 focus:ring-cyan-500/20 transition-smooth"
                />
              </div>
            </GlassCard>

            {/* Category Selection */}
            <GlassCard variant="default" className="mb-6">
              <label className="text-white font-semibold block mb-4">Category</label>
              <div className="grid grid-cols-5 gap-2">
                {categories.map((cat) => (
                  <button
                    key={cat.value}
                    className="flex flex-col items-center gap-2 p-3 rounded-xl bg-white/5 border border-white/10 hover:border-cyan-400/50 hover:bg-cyan-500/10 transition-smooth"
                  >
                    <span className="text-2xl">{cat.icon}</span>
                    <span className="text-xs text-white/60 text-center font-medium">{cat.label}</span>
                  </button>
                ))}
              </div>
            </GlassCard>

            {/* Description */}
            <GlassCard variant="default" className="mb-6">
              <label className="text-white/60 text-sm block mb-2 font-medium">Description (Optional)</label>
              <input
                type="text"
                placeholder="What was it for?"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-white placeholder-white/20 focus:outline-none focus:border-cyan-400/50 focus:ring-2 focus:ring-cyan-500/20 transition-smooth"
              />
            </GlassCard>

            {/* Date */}
            <GlassCard variant="default" className="mb-6">
              <label className="text-white/60 text-sm block mb-2 font-medium">Date</label>
              <input
                type="date"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-cyan-400/50 focus:ring-2 focus:ring-cyan-500/20 transition-smooth"
              />
            </GlassCard>

            {/* Submit Button */}
            <button className="w-full py-4 px-6 rounded-xl bg-gradient-to-r from-cyan-500 to-cyan-400 text-[#050811] font-bold text-lg hover:shadow-lg hover:shadow-cyan-500/50 transition-smooth hover:scale-105">
              <Plus size={20} className="inline mr-2" />
              Add Expense
            </button>
          </>
        ) : (
          <>
            {/* Receipt Uploader */}
            <GlassCard variant="accent" className="mb-6 flex flex-col items-center justify-center py-12 border-2 border-dashed border-cyan-400/30 hover:border-cyan-400/50 transition-smooth">
              <Camera size={48} className="text-cyan-400 mb-4" />
              <p className="text-white font-semibold mb-2">Take a photo</p>
              <p className="text-white/60 text-sm text-center mb-4 max-w-xs">
                Take a photo of your receipt and we&apos;ll automatically extract the details
              </p>
              <button className="px-6 py-3 bg-gradient-to-r from-cyan-500/30 to-cyan-400/20 border border-cyan-400/50 text-cyan-300 rounded-xl font-semibold hover:from-cyan-500/40 hover:to-cyan-400/30 transition-smooth glow-cyan">
                <Camera size={18} className="inline mr-2" />
                Open Camera
              </button>
            </GlassCard>

            {/* Or upload */}
            <div className="flex items-center gap-3 mb-6">
              <div className="flex-1 h-px bg-gradient-to-r from-white/5 via-white/10 to-white/5" />
              <span className="text-white/40 text-sm font-medium">or</span>
              <div className="flex-1 h-px bg-gradient-to-r from-white/5 via-white/10 to-white/5" />
            </div>

            <GlassCard variant="default" className="mb-6 flex flex-col items-center justify-center py-8 border-2 border-dashed border-white/15 hover:border-cyan-400/30 cursor-pointer transition-smooth">
              <Upload size={40} className="text-white/40 mb-2" />
              <p className="text-white/60 text-sm font-medium">Upload from gallery</p>
            </GlassCard>

            {/* Info */}
            <GlassCard variant="default" className="text-center">
              <p className="text-white/50 text-sm">
                We support JPG, PNG, and PDF files up to 5MB
              </p>
            </GlassCard>
          </>
        )}
      </div>

      <BottomNav />
    </main>
  );
}
