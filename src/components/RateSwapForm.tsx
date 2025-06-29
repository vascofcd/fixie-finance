"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { useAccount, useChainId, useWriteContract } from "wagmi";
import {
  Box,
  Typography,
  Grid,
  FormControl,
  InputLabel,
  OutlinedInput,
  InputAdornment,
  Button,
} from "@mui/material";
import { BarChart } from "@mui/icons-material";
import { chainsToContracts, RATE_SWAP_ABI } from "@/constants";

interface SwapFormData {
  notional: bigint;
  fixedRate: bigint;
  term: bigint;
}

interface SwapFormProps {
  currentFloatingRate: number;
}
//approve
const RateSwapForm = ({ currentFloatingRate }: SwapFormProps) => {
  const { address } = useAccount();

  const chainId = useChainId();

  const [formData, setFormData] = useState<SwapFormData>({
    notional: BigInt(100000),
    fixedRate: BigInt(3),
    term: BigInt(30), // in days
  });

  const rateSwapAddress =
    (chainsToContracts[chainId]?.rateSwapContract as `0x${string}`) || "0x";

  const asset =
    (chainsToContracts[chainId]?.usdcAddress as `0x${string}`) || "0x";

  const handleChange =
    (field: keyof SwapFormData) => (e: React.ChangeEvent<HTMLInputElement>) => {
      setFormData({
        ...formData,
        [field]: parseFloat(e.target.value) || 0,
      });
    };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log("Submitting swap with rateSwapAddress:", rateSwapAddress);
    const { notional, fixedRate, term } = formData;

    try {
      writeContract({
        abi: RATE_SWAP_ABI,
        address: rateSwapAddress,
        functionName: "createSwap",
        args: [notional, fixedRate, term, asset],
      });
    } catch (error) {
      console.error("Error creating swap:", error);
    }
  };

  const { data, isPending, writeContract, error } = useWriteContract();

  console.log("Write Contract Data:", data);
  console.log("Write Contract Pending:", isPending);
  console.log("Write Contract Error:", error);
  return (
    <Box>
      <Box sx={{ display: "flex", alignItems: "center", gap: 2, mb: 3 }}>
        <BarChart color="primary" sx={{ fontSize: 32 }} />
        <Typography variant="h5">Fixed Rate Receiver</Typography>
      </Box>

      <Grid container spacing={2}>
        <FormControl fullWidth>
          <InputLabel htmlFor="notional-amount">Notional Amount</InputLabel>
          <OutlinedInput
            id="notional-amount"
            value={formData.notional}
            onChange={handleChange("notional")}
            startAdornment={<InputAdornment position="start">$</InputAdornment>}
            label="Notional Amount"
            type="number"
            inputProps={{ min: 0, step: 1000 }}
          />
        </FormControl>

        <FormControl fullWidth>
          <InputLabel htmlFor="fixed-rate">Fixed Rate</InputLabel>
          <OutlinedInput
            id="fixed-rate"
            value={formData.fixedRate}
            onChange={handleChange("fixedRate")}
            endAdornment={<InputAdornment position="end">%</InputAdornment>}
            label="Fixed Rate"
            type="number"
            inputProps={{ min: 0, max: 100, step: 0.1 }}
          />
        </FormControl>

        <Box
          sx={{
            p: 2,
            border: "1px dashed",
            borderRadius: 1,
            borderColor: "divider",
          }}
        >
          <Typography variant="body1" textAlign="center">
            Current Floating Rate: <strong>{currentFloatingRate}%</strong>
          </Typography>
          <Typography
            variant="caption"
            color="text.secondary"
            display="block"
            textAlign="center"
          >
            (Based on current Aave rates)
          </Typography>
        </Box>

        <Box sx={{ p: 2, bgcolor: "action.hover", borderRadius: 1 }}>
          <Typography variant="body1" textAlign="center">
            You'll pay <strong>{formData.fixedRate}%</strong> fixed and receive
            <strong>{currentFloatingRate}%</strong> floating
          </Typography>
        </Box>

        <Button
          type="submit"
          variant="contained"
          size="large"
          fullWidth
          onClick={handleSubmit}
          disabled={formData.notional <= 0 || formData.fixedRate <= 0}
        >
          Create Swap Contract
        </Button>

        {/* <GradientButton fullWidth onClick={handleSubmit} disabled={false}>
          Create Swap Position
        </GradientButton> */}
      </Grid>
    </Box>
  );
};

export default RateSwapForm;
