'use client';

import { GlassCard } from './glass-card';
import { TrendingDown, Wallet, Target } from 'lucide-react';
import { cn } from '@/lib/utils';

interface StatsCardProps {
  icon: React.ReactNode;
  label: string;
  value: string;
  trend?: string;
  trendUp?: boolean;
  className?: string;
}

function StatsCard({ icon, label, value, trend, trendUp, className }: StatsCardProps) {
  return (
    <GlassCard variant="premium" className={cn("flex-1 min-w-max relative overflow-hidden group", className)}>
      <div className="absolute inset-0 bg-gradient-to-br from-white/5 to-transparent opacity-0 group-hover:opacity-100 transition-smooth rounded-3xl"></div>
      <div className="relative z-10">
        <div className="flex items-start justify-between mb-3">
          <div className="p-3 rounded-xl bg-gradient-to-br from-white/15 to-white/5 border border-white/10 shadow-lg">
            {icon}
          </div>
          {trend && (
            <span className={cn("text-xs font-bold px-2 py-1 rounded-full", 
              trendUp ? "bg-red-500/20 text-red-300 border border-red-400/30" : "bg-green-500/20 text-green-300 border border-green-400/30"
            )}>
              {trend}
            </span>
          )}
        </div>
        <p className="text-white/60 text-sm mb-1 font-medium">{label}</p>
        <p className="text-2xl font-bold text-white">{value}</p>
      </div>
    </GlassCard>
  );
}

export function DashboardStats() {
  return (
    <div className="flex gap-3 pb-4 overflow-x-auto scrollbar-hide">
      <StatsCard
        icon={<Wallet size={20} className="text-[#00D9FF]" />}
        label="Total Spent"
        value="$2,450"
        trend="+12.5%"
        trendUp
      />
      <StatsCard
        icon={<TrendingDown size={20} className="text-[#FF6B6B]" />}
        label="This Month"
        value="$1,820"
        trend="-5.2%"
      />
      <StatsCard
        icon={<Target size={20} className="text-[#4ECDC4]" />}
        label="Budget Left"
        value="$680"
      />
    </div>
  );
}
