// components/ui/GradientButton.tsx
"use client";

import { ReactNode } from "react";
import { Button, ButtonProps, styled } from "@mui/material";

interface GradientButtonProps extends ButtonProps {
  children: ReactNode;
  glowEffect?: boolean;
}

const PixieGradientButton = styled(Button)<GradientButtonProps>(
  ({ theme, glowEffect = true }) => ({
    background: "linear-gradient(to right, #c5b3e6, #a8b2d1)",
    color: theme.palette.common.white,
    borderRadius: "12px",
    padding: "12px 24px",
    fontWeight: 600,
    textTransform: "none",
    position: "relative",
    overflow: "hidden",
    transition: "all 0.3s ease",
    boxShadow: glowEffect ? "0 4px 15px rgba(197, 179, 230, 0.4)" : "none",

    "&:before": {
      content: '""',
      position: "absolute",
      top: 0,
      left: "-100%",
      width: "100%",
      height: "100%",
      background:
        "linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent)",
      transition: "0.5s",
    },

    "&:hover": {
      transform: "translateY(-2px)",
      boxShadow: glowEffect ? "0 6px 20px rgba(197, 179, 230, 0.6)" : "none",

      "&:before": {
        left: "100%",
      },
    },

    "&.Mui-disabled": {
      background: theme.palette.grey[300],
      boxShadow: "none",
    },
  })
);

export const GradientButton = ({
  children,
  glowEffect = true,
  ...props
}: GradientButtonProps) => {
  return (
    <PixieGradientButton glowEffect={glowEffect} {...props}>
      {children}
    </PixieGradientButton>
  );
};
