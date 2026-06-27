'use client';

import { BottomNav } from '@/components/bottom-nav';
import { GlassCard } from '@/components/glass-card';
import { ArrowLeft, LogOut, Bell, Lock, FileText, HelpCircle } from 'lucide-react';
import Link from 'next/link';

export default function Profile() {
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
          <h1 className="text-2xl font-bold text-white">Profile</h1>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-md mx-auto px-6 pt-6 relative z-10">
        {/* User Card */}
        <GlassCard variant="premium" className="mb-6 text-center relative">
          <div className="absolute inset-0 rounded-3xl bg-gradient-to-br from-cyan-500/10 via-transparent to-purple-500/10 pointer-events-none"></div>
          <div className="relative z-10">
            <div className="w-24 h-24 rounded-full bg-gradient-to-br from-cyan-400 to-purple-500 mx-auto mb-4 shadow-lg glow-cyan" />
            <h2 className="text-3xl font-bold text-white mb-1">Alex Johnson</h2>
            <p className="text-white/50 mb-4 font-medium">alex@example.com</p>
            <button className="px-6 py-3 bg-gradient-to-r from-cyan-500/30 to-cyan-400/20 border border-cyan-400/50 text-cyan-300 rounded-xl hover:from-cyan-500/40 hover:to-cyan-400/30 transition-smooth glow-cyan font-semibold">
              Edit Profile
            </button>
          </div>
        </GlassCard>

        {/* Account Stats */}
        <div className="grid grid-cols-3 gap-3 mb-6">
          <GlassCard variant="default" className="text-center">
            <p className="text-white/60 text-sm mb-2 font-medium">Total Expenses</p>
            <p className="text-2xl font-bold text-white">247</p>
          </GlassCard>
          <GlassCard variant="default" className="text-center">
            <p className="text-white/60 text-sm mb-2 font-medium">This Month</p>
            <p className="text-2xl font-bold text-cyan-300">$1.8K</p>
          </GlassCard>
          <GlassCard variant="default" className="text-center">
            <p className="text-white/60 text-sm mb-2 font-medium">Balance</p>
            <p className="text-2xl font-bold text-white">$4.2K</p>
          </GlassCard>
        </div>

        {/* Settings Sections */}
        <div className="space-y-4">
          {/* Preferences */}
          <h3 className="text-white font-bold text-lg px-2 flex items-center gap-2">
            <span className="inline-block w-1 h-5 bg-gradient-to-b from-cyan-400 to-purple-400 rounded"></span>
            Preferences
          </h3>

          <GlassCard variant="default" className="flex items-center justify-between cursor-pointer group hover:scale-102 transition-smooth">
            <div className="flex items-center gap-3">
              <Bell size={20} className="text-cyan-400" />
              <p className="text-white font-semibold">Notifications</p>
            </div>
            <div className="w-12 h-6 rounded-full bg-cyan-500/20 border border-cyan-400/50 relative">
              <div className="w-5 h-5 rounded-full bg-cyan-400 absolute right-0.5 top-0.5 shadow-lg" />
            </div>
          </GlassCard>

          <GlassCard variant="default" className="flex items-center justify-between cursor-pointer group hover:scale-102 transition-smooth">
            <div className="flex items-center gap-3">
              <Lock size={20} className="text-white/60" />
              <p className="text-white font-semibold">Privacy Settings</p>
            </div>
            <span className="text-white/40">{'>>'}</span>
          </GlassCard>

          {/* Account */}
          <h3 className="text-white font-bold text-lg px-2 mt-6 flex items-center gap-2">
            <span className="inline-block w-1 h-5 bg-gradient-to-b from-cyan-400 to-purple-400 rounded"></span>
            Account
          </h3>

          <GlassCard variant="default" className="flex items-center justify-between cursor-pointer group hover:scale-102 transition-smooth">
            <div className="flex items-center gap-3">
              <FileText size={20} className="text-white/60" />
              <p className="text-white font-semibold">Terms & Privacy</p>
            </div>
            <span className="text-white/40">{'>>'}</span>
          </GlassCard>

          <GlassCard variant="default" className="flex items-center justify-between cursor-pointer group hover:scale-102 transition-smooth">
            <div className="flex items-center gap-3">
              <HelpCircle size={20} className="text-white/60" />
              <p className="text-white font-semibold">Help & Support</p>
            </div>
            <span className="text-white/40">{'>>'}</span>
          </GlassCard>

          <GlassCard variant="default" className="flex items-center justify-between cursor-pointer group hover:bg-red-500/10 hover:border-red-400/30 transition-smooth">
            <div className="flex items-center gap-3">
              <LogOut size={20} className="text-red-400" />
              <p className="text-red-400 font-semibold">Logout</p>
            </div>
            <span className="text-white/40">{'>>'}</span>
          </GlassCard>
        </div>

        {/* Footer */}
        <div className="text-center mt-8">
          <p className="text-white/40 text-xs font-medium">Version 1.0.0</p>
        </div>
      </div>

      <BottomNav />
    </main>
  );
}
