"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { Menu } from "@mui/icons-material";
import {
  AppBar,
  Toolbar,
  Box,
  Typography,
  Button,
  IconButton,
  Avatar,
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemText,
} from "@mui/material";

export const Header = () => {
  const pathname = usePathname();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [walletConnected, setWalletConnected] = useState(false);

  const navItems = [
    { name: "Dashboard", path: "/dashboard" },
    { name: "Swap", path: "/dashboard/swap" },
    { name: "Positions", path: "/dashboard/positions" },
    { name: "Markets", path: "/markets" },
    { name: "Docs", path: "/docs" },
  ];

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const handleConnectWallet = () => {
    setWalletConnected(!walletConnected);
  };

  const drawer = (
    <Box sx={{ width: 250 }} role="presentation">
      <List>
        {navItems.map((item) => (
          <ListItem key={item.name} disablePadding>
            <ListItemButton
              component={Link}
              href={item.path}
              selected={pathname === item.path}
            >
              <ListItemText primary={item.name} />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </Box>
  );

  return (
    <>
      <AppBar
        position="static"
        color="transparent"
        elevation={0}
        sx={{
          borderBottom: "1px solid rgba(197, 179, 230, 0.3)",
          backdropFilter: "blur(10px)",
          backgroundColor: "rgba(255, 255, 255, 0.7)",
        }}
      >
        <Toolbar>
          {/* Mobile menu button */}
          <IconButton
            color="inherit"
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { md: "none" } }}
          >
            <Menu />
          </IconButton>

          {/* Logo */}
          <Box
            sx={{
              display: "flex",
              alignItems: "center",
              gap: 2,
              flexGrow: { xs: 1, md: 0 },
              mr: { md: 4 },
            }}
          >
            <Avatar
              sx={{
                bgcolor: "primary.main",
                width: 50,
                height: 50,
                boxShadow: "0 4px 15px rgba(197, 179, 230, 0.4)",
              }}
            >
              <Image
                src="/vercel.svg"
                alt="Pixie Finance"
                width={28}
                height={28}
              />
            </Avatar>
            <Box sx={{ display: { xs: "none", sm: "block" } }}>
              <Typography variant="h6" sx={{ fontWeight: 700 }}>
                Fixie Finance
              </Typography>
              <Typography variant="caption" sx={{ color: "text.secondary" }}>
                Enchanted Swaps
              </Typography>
            </Box>
          </Box>

          {/* Desktop Navigation */}
          <Box
            sx={{
              display: { xs: "none", md: "flex" },
              gap: 1,
              flexGrow: 1,
            }}
          >
            {navItems.map((item) => (
              <Button
                key={item.name}
                component={Link}
                href={item.path}
                sx={{
                  color:
                    pathname === item.path ? "primary.main" : "text.secondary",
                  fontWeight: 500,
                  position: "relative",
                  "&:after": {
                    content: '""',
                    position: "absolute",
                    bottom: 0,
                    left: "50%",
                    width: pathname === item.path ? "70%" : 0,
                    height: "2px",
                    background: "primary.main",
                    transform: "translateX(-50%)",
                    transition: "width 0.3s",
                  },
                  "&:hover:after": {
                    width: "70%",
                  },
                }}
              >
                {item.name}
              </Button>
            ))}
          </Box>

          <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
            <ConnectButton />
          </Box>
        </Toolbar>
      </AppBar>

      {/* Mobile Drawer */}
      <Drawer
        variant="temporary"
        open={mobileOpen}
        onClose={handleDrawerToggle}
        ModalProps={{
          keepMounted: true, // Better open performance on mobile.
        }}
        sx={{
          display: { xs: "block", md: "none" },
          "& .MuiDrawer-paper": {
            boxSizing: "border-box",
            width: 250,
            backgroundColor: "background.paper",
          },
        }}
      >
        {drawer}
      </Drawer>
    </>
  );
};
