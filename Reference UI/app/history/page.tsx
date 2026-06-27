'use client';

import { BottomNav } from '@/components/bottom-nav';
import { GlassCard } from '@/components/glass-card';
import { ExpenseTile } from '@/components/recent-expenses';
import { ArrowLeft, Search, Filter } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';

export default function History() {
  const [searchTerm, setSearchTerm] = useState('');

  const allExpenses = [
    { category: 'Starbucks', categoryIcon: '☕', amount: '5.50', date: 'Today', description: 'Coffee', color: 'food' },
    { category: 'Uber', categoryIcon: '🚗', amount: '12.30', date: 'Today', description: 'Ride', color: 'transport' },
    { category: 'Whole Foods', categoryIcon: '🛒', amount: '84.22', date: 'Yesterday', description: 'Groceries', color: 'food' },
    { category: 'Gas Station', categoryIcon: '⛽', amount: '45.00', date: 'Yesterday', description: 'Fuel', color: 'transport' },
    { category: 'Target', categoryIcon: '🛍️', amount: '85.00', date: '2 days ago', description: 'Shopping', color: 'shopping' },
    { category: 'Netflix', categoryIcon: '🎬', amount: '15.99', date: '3 days ago', description: 'Subscription', color: 'entertainment' },
    { category: 'Pizza Hut', categoryIcon: '🍕', amount: '28.50', date: '4 days ago', description: 'Dinner', color: 'food' },
  ];

  const filteredExpenses = allExpenses.filter((expense) =>
    expense.category.toLowerCase().includes(searchTerm.toLowerCase()) ||
    expense.description.toLowerCase().includes(searchTerm.toLowerCase())
  );

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
          <h1 className="text-2xl font-bold text-white">History</h1>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-md mx-auto px-6 pt-6 relative z-10">
        {/* Search and Filter */}
        <div className="flex gap-2 mb-6">
          <div className="flex-1 relative">
            <Search size={18} className="absolute left-4 top-3.5 text-white/40" />
            <input
              type="text"
              placeholder="Search expenses..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full bg-white/5 border border-white/10 rounded-xl pl-10 pr-4 py-3 text-white placeholder-white/20 focus:outline-none focus:border-cyan-400/50 focus:ring-2 focus:ring-cyan-500/20 transition-smooth"
            />
          </div>
          <button className="p-3 rounded-xl bg-white/5 border border-white/10 hover:border-cyan-400/50 hover:bg-cyan-500/10 transition-smooth">
            <Filter size={18} className="text-white" />
          </button>
        </div>

        {/* Expenses grouped by date */}
        <div className="space-y-6">
          {['Today', 'Yesterday', '2 days ago', '3 days ago', '4 days ago'].map((date) => {
            const dayExpenses = filteredExpenses.filter((e) => e.date === date);
            if (dayExpenses.length === 0) return null;

            const dayTotal = dayExpenses.reduce((sum, e) => sum + parseFloat(e.amount), 0);

            return (
              <div key={date}>
                <div className="flex items-center justify-between mb-3 px-2">
                  <p className="text-white/60 font-semibold text-sm">{date}</p>
                  <p className="text-cyan-400 font-bold">${dayTotal.toFixed(2)}</p>
                </div>
                <div className="space-y-2">
                  {dayExpenses.map((expense, idx) => (
                    <ExpenseTile key={idx} {...expense} />
                  ))}
                </div>
              </div>
            );
          })}
        </div>

        {filteredExpenses.length === 0 && (
          <GlassCard variant="default" className="text-center py-12">
            <p className="text-white/50">No expenses found</p>
          </GlassCard>
        )}

        {/* Summary */}
        <GlassCard variant="premium" className="mt-8 relative">
          <div className="absolute inset-0 rounded-3xl bg-gradient-to-br from-cyan-500/10 via-transparent to-purple-500/10 pointer-events-none"></div>
          <div className="grid grid-cols-2 gap-4 relative z-10">
            <div>
              <p className="text-white/60 text-sm mb-1 font-medium">Total This Month</p>
              <p className="text-2xl font-bold text-cyan-300">$1,820</p>
            </div>
            <div>
              <p className="text-white/60 text-sm mb-1 font-medium">Average Per Day</p>
              <p className="text-2xl font-bold text-white">$72.80</p>
            </div>
          </div>
        </GlassCard>
      </div>

      <BottomNav />
    </main>
  );
}
