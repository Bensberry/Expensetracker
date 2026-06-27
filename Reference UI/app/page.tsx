'use client';

import { BottomNav } from '@/components/bottom-nav';
import { GlassCard } from '@/components/glass-card';
import { DashboardStats } from '@/components/dashboard-stats';
import { SpendingChart } from '@/components/spending-chart';
import { RecentExpenses } from '@/components/recent-expenses';
import { Zap, Sparkles } from 'lucide-react';

export default function Dashboard() {
  return (
    <main className="min-h-screen bg-gradient-to-br from-[#050811] via-[#0a0f1f] to-[#050811] grain pb-24 relative overflow-hidden">
      {/* Animated background elements */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        <div className="absolute top-20 right-10 w-72 h-72 bg-cyan-500/5 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-40 left-10 w-96 h-96 bg-purple-500/5 rounded-full blur-3xl animate-pulse" style={{ animationDelay: '1s' }}></div>
      </div>

      {/* Header */}
      <div className="sticky top-0 z-40 bg-gradient-to-b from-[#050811] via-[#050811]/90 to-[#050811]/50 backdrop-blur-xl border-b border-white/5 p-6 relative">
        <div className="max-w-md mx-auto">
          <div className="flex items-center justify-between mb-2">
            <div>
              <p className="text-white/60 text-sm font-medium">Good morning</p>
              <h1 className="text-4xl font-bold text-white">Alex</h1>
            </div>
            <div className="p-4 rounded-full bg-gradient-to-br from-white/10 to-white/5 border border-cyan-400/30 shadow-lg glow-cyan">
              <Sparkles size={24} className="text-cyan-400" />
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-md mx-auto px-6 pt-6 relative z-10">
        {/* Stats Cards */}
        <DashboardStats />

        {/* Hero Card */}
        <GlassCard variant="premium" className="mb-6 relative">
          <div className="absolute inset-0 rounded-3xl bg-gradient-to-br from-cyan-500/10 via-transparent to-purple-500/10 pointer-events-none"></div>
          <div className="text-center relative z-10">
            <p className="text-white/60 text-sm mb-2 font-medium">Your balance</p>
            <h2 className="text-6xl font-bold bg-gradient-to-r from-white via-white to-cyan-200 bg-clip-text text-transparent mb-6">$4,250.00</h2>
            <div className="grid grid-cols-2 gap-3">
              <button className="py-3 px-4 rounded-xl bg-gradient-to-r from-cyan-500/30 to-cyan-400/20 border border-cyan-400/50 text-cyan-300 font-semibold hover:from-cyan-500/40 hover:to-cyan-400/30 hover:border-cyan-300/80 transition-smooth shadow-lg glow-cyan">
                Send Money
              </button>
              <button className="py-3 px-4 rounded-xl bg-white/10 border border-white/20 text-white font-semibold hover:bg-white/15 hover:border-white/30 transition-smooth">
                Request
              </button>
            </div>
          </div>
        </GlassCard>

        {/* Spending Chart */}
        <GlassCard variant="default" className="mb-6">
          <h3 className="text-white font-bold text-lg mb-4 flex items-center gap-2">
            <span className="inline-block w-1 h-5 bg-gradient-to-b from-cyan-400 to-purple-400 rounded"></span>
            Weekly Spending
          </h3>
          <SpendingChart />
        </GlassCard>

        {/* Recent Expenses */}
        <RecentExpenses />
      </div>

      <BottomNav />
    </main>
  );
}
