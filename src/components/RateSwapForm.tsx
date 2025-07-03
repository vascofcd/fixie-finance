"use client";

import { useState } from "react";
import { useAccount, useChainId, useWriteContract } from "wagmi";
import {
  Box,
  Typography,
  FormControl,
  Button,
  FormLabel,
  RadioGroup,
  FormControlLabel,
  Radio,
  TextField,
  CircularProgress,
  Alert,
  Slider,
} from "@mui/material";
import { chainsToContracts, RATE_SWAP_ABI, USDC_ABI } from "@/constants";

const MAX_LEVERAGE = 10;

const RateSwapForm = () => {
  const { address } = useAccount();
  const chainId = useChainId();

  const rateSwapAddr =
    (chainsToContracts[chainId]?.rateSwap as `0x${string}`) || "0x";

  const assetAddr =
    (chainsToContracts[chainId]?.USDCAddr as `0x${string}`) || "0x";

  const [collateralAmt, setCollateralAmt] = useState<number>(100);
  const [leverage, setLeverage] = useState<number>(5);
  const [tenor, setTenor] = useState<number>(90);
  const [payFixed, setPayFixed] = useState<boolean>(true);

  const [status, setStatus] = useState<string>("");
  const [loading, setLoading] = useState<boolean>(false);

  const {
    data: approvalHash,
    isPending: isApprovalPending,
    writeContract: approveToken,
    error: approvalError,
  } = useWriteContract();

  const {
    data: swapHash,
    isPending: isOpeningSwap,
    writeContract: openSwap,
    error: swapError,
  } = useWriteContract();

  const handleApprove = async () => {
    if (!collateralAmt) return;

    try {
      approveToken({
        abi: USDC_ABI,
        address: assetAddr,
        functionName: "approve",
        args: [rateSwapAddr, collateralAmt],
      });
    } catch (error) {
      console.error("Error approving token:", error);
    }
  };

  const handleOpenSwap = () => {
    console.log("collateralAmt", collateralAmt);
    console.log("leverage", leverage);
    console.log("tenor", tenor);
    console.log("payFixed", payFixed);

    try {
      openSwap({
        abi: RATE_SWAP_ABI,
        address: rateSwapAddr,
        functionName: "openSwap",
        args: [payFixed, collateralAmt, leverage, 5000, tenor],
      });
    } catch (error) {
      console.error("Error creating swap:", error);
    }
  };

  console.log("Write Contract Data:", swapHash);
  console.log("Write Contract Pending:", isOpeningSwap);
  console.log("Write Contract Error:", swapError);
  return (
    <Box sx={{ maxWidth: 500, mx: "auto", p: 4 }}>
      <Typography variant="h4" gutterBottom>
        Open Rate Swap
      </Typography>

      <TextField
        fullWidth
        label="Collateral (USDC)"
        type="number"
        value={collateralAmt}
        onChange={(e) => setCollateralAmt(Number(e.target.value))}
        sx={{ mb: 3 }}
      />

      <FormLabel sx={{ mb: 1 }}>Leverage: {leverage}×</FormLabel>
      <Slider
        value={leverage}
        min={1}
        max={MAX_LEVERAGE}
        step={1}
        onChange={(_, val) => setLeverage(val as number)}
        sx={{ mb: 3 }}
      />

      <FormControl sx={{ mb: 3 }}>
        <FormLabel>Direction</FormLabel>
        <RadioGroup
          row
          value={payFixed ? "PAY_FIXED" : "PAY_FLOAT"}
          onChange={(e) => setPayFixed(e.target.value === "PAY_FIXED")}
        >
          <FormControlLabel
            value="PAY_FIXED"
            control={<Radio />}
            label="Pay Fixed"
          />
          <FormControlLabel
            value="PAY_FLOAT"
            control={<Radio />}
            label="Pay Float"
          />
        </RadioGroup>
      </FormControl>

      <TextField
        fullWidth
        label="Tenor (days)"
        type="number"
        value={tenor}
        onChange={(e) => setTenor(Number(e.target.value))}
        sx={{ mb: 3 }}
      />

      {!!address && (
        <>
          <Button
            fullWidth
            variant="outlined"
            onClick={() => {
              handleApprove();
            }}
            sx={{ mb: 2 }}
            disabled={loading}
          >
            {loading ? <CircularProgress size={24} /> : "Approve USDC"}
          </Button>

          <Button
            fullWidth
            variant="contained"
            onClick={() => {
              handleOpenSwap();
            }}
            disabled={loading}
          >
            {loading ? <CircularProgress size={24} /> : "Open Swap"}
          </Button>
        </>
      )}

      {status && (
        <Alert severity="info" sx={{ mt: 3 }}>
          {status}
        </Alert>
      )}
    </Box>
  );
};

export default RateSwapForm;
