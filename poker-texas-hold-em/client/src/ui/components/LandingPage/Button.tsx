import { ReactNode } from 'react';

type ButtonVariant = 
  | 'gradient' 
  | 'transparent'
  | 'solid-red'
  | 'solid-yellow'
  | 'outline-red'
  | 'outline-yellow';

type ButtonSize = 'sm' | 'md' | 'lg';
type ButtonRadius = 'none' | 'sm' | 'md' | 'lg' | 'full';

interface ButtonProps {
  children: ReactNode;
  variant?: ButtonVariant;
  size?: ButtonSize;
  radius?: ButtonRadius;
  fullWidth?: boolean;
  className?: string;
  onClick?: () => void;
  disabled?: boolean;
}

const Button = ({
  children,
  variant = 'solid-red',
  size = 'md',
  radius = 'md',
  fullWidth = false,
  className = '',
  onClick,
  disabled = false,
}: ButtonProps) => {
  // Base classes
  const baseClasses = 'font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed';

  // Variant classes
  const variantClasses = {
    'gradient': 'bg-gradient-to-r from-[#B31926] to-[#4D0B10] text-white border-3 border-transparent border-gradient-to-r from-[#FFD700] to-[#B7860F]',
    'transparent': 'bg-transparent text-gray-800 hover:bg-gray-100 focus:ring-gray-300 dark:text-white dark:hover:bg-gray-800',
    'solid-red': 'bg-[#B31926] text-white hover:bg-[#8A0F1A] border-3 border-[#FFD700]',
    'solid-yellow': 'bg-[#FFD700] text-black hover:bg-[#E5C100] border-3 border-[#B31926]',
    'outline-red': 'bg-transparent text-[#B31926] border-3 border-[#B31926] hover:bg-red-50',
    'outline-yellow': 'bg-transparent text-[#FFD700] border-3 border-[#FFD700] hover:bg-yellow-50'
  };

  // Size classes
  const sizeClasses = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg',
  };

  // Radius classes
  const radiusClasses = {
    none: 'rounded-none',
    sm: 'rounded-sm',
    md: 'rounded-md',
    lg: 'rounded-lg',
    full: 'rounded-full',
  };

  // Width class
  const widthClass = fullWidth ? 'w-full' : 'w-fit';

  return (
    <button
      className={`
        ${baseClasses}
        ${variantClasses[variant]}
        ${sizeClasses[size]}
        ${radiusClasses[radius]}
        ${widthClass}
        ${className}
      `}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
};

export default Button;