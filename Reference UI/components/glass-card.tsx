import { cn } from "@/lib/utils";

interface GlassCardProps {
  children: React.ReactNode;
  className?: string;
  variant?: "default" | "premium" | "accent";
}

export function GlassCard({ children, className, variant = "default" }: GlassCardProps) {
  const variants = {
    default: "bg-white/5 backdrop-blur-xl border border-white/10 hover:bg-white/7 hover:border-white/20",
    premium: "bg-gradient-to-br from-white/10 to-white/5 backdrop-blur-2xl border border-white/20 shadow-[0_8px_32px_rgba(0,217,255,0.1)] hover:shadow-[0_8px_32px_rgba(0,217,255,0.2)] hover:border-white/30",
    accent: "bg-gradient-to-br from-cyan-500/10 to-blue-500/5 backdrop-blur-2xl border border-cyan-400/30 shadow-[0_0_20px_rgba(0,217,255,0.15)]",
  };

  return (
    <div
      className={cn(
        "rounded-3xl p-6 transition-smooth glass-shimmer",
        variants[variant],
        className
      )}
    >
      {children}
    </div>
  );
}
