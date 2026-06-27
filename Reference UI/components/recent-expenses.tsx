'use client';

import { GlassCard } from './glass-card';
import { Trash2, Calendar, Tag } from 'lucide-react';
import { cn } from '@/lib/utils';

interface ExpenseTileProps {
  category: string;
  categoryIcon: string;
  amount: string;
  date: string;
  description: string;
  color: string;
}

const categoryColors: Record<string, string> = {
  food: 'bg-orange-400/20 text-orange-300',
  transport: 'bg-blue-400/20 text-blue-300',
  shopping: 'bg-pink-400/20 text-pink-300',
  utilities: 'bg-green-400/20 text-green-300',
  entertainment: 'bg-purple-400/20 text-purple-300',
};

export function ExpenseTile({
  category,
  categoryIcon,
  amount,
  date,
  description,
  color,
}: ExpenseTileProps) {
  return (
    <GlassCard variant="default" className="flex items-center justify-between gap-4 mb-3 group hover:scale-102 transition-smooth">
      <div className="flex items-center gap-3 flex-1 min-w-0">
        <div className={cn("p-3 rounded-xl text-xl font-bold shadow-md group-hover:shadow-lg transition-smooth", categoryColors[color] || categoryColors.food)}>
          {categoryIcon}
        </div>
        <div className="flex-1 min-w-0">
          <p className="font-semibold text-white truncate">{category}</p>
          <p className="text-sm text-white/50 truncate">{description}</p>
        </div>
      </div>
      <div className="text-right">
        <p className="font-bold text-cyan-300 text-lg">${amount}</p>
        <p className="text-xs text-white/40">{date}</p>
      </div>
    </GlassCard>
  );
}

export function RecentExpenses() {
  const expenses = [
    { category: 'Starbucks', categoryIcon: '☕', amount: '5.50', date: 'Today', description: 'Coffee', color: 'food' },
    { category: 'Uber', categoryIcon: '🚗', amount: '12.30', date: 'Yesterday', description: 'Ride', color: 'transport' },
    { category: 'Target', categoryIcon: '🛍️', amount: '85.00', date: '2 days ago', description: 'Shopping', color: 'shopping' },
    { category: 'Netflix', categoryIcon: '🎬', amount: '15.99', date: '3 days ago', description: 'Subscription', color: 'entertainment' },
  ];

  return (
    <div className="mt-8">
      <div className="flex items-center gap-2 mb-4">
        <span className="inline-block w-1 h-5 bg-gradient-to-b from-cyan-400 to-purple-400 rounded"></span>
        <h3 className="text-white font-bold text-lg">Recent Expenses</h3>
      </div>
      <div className="space-y-2">
        {expenses.map((expense, idx) => (
          <ExpenseTile key={idx} {...expense} />
        ))}
      </div>
    </div>
  );
}
