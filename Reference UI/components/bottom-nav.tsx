'use client';

import { Home, Plus, History, User } from 'lucide-react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from "@/lib/utils";

const navItems = [
  { icon: Home, label: 'Home', href: '/' },
  { icon: Plus, label: 'Add', href: '/add-expense' },
  { icon: History, label: 'History', href: '/history' },
  { icon: User, label: 'Profile', href: '/profile' },
];

export function BottomNav() {
  const pathname = usePathname();

  return (
    <nav className="fixed bottom-0 left-0 right-0 border-t border-white/10 bg-gradient-to-t from-[#0B0F19] to-[#0B0F19]/80 backdrop-blur-xl">
      <div className="max-w-md mx-auto flex items-center justify-around h-20 px-4">
        {navItems.map(({ icon: Icon, label, href }) => {
          const isActive = pathname === href;
          return (
            <Link
              key={href}
              href={href}
              className="flex flex-col items-center justify-center gap-1 flex-1 py-2 px-3 rounded-lg transition-all duration-300"
            >
              <Icon
                size={24}
                className={cn(
                  "transition-all duration-300",
                  isActive ? "text-[#00D9FF] scale-110" : "text-white/60 hover:text-white/80"
                )}
              />
              <span
                className={cn(
                  "text-xs font-medium transition-all duration-300",
                  isActive ? "text-[#00D9FF]" : "text-white/60"
                )}
              >
                {label}
              </span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
