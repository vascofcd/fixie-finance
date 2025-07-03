import { Container, Box, Typography } from "@mui/material";
import RateSwapForm from "@/components/RateSwapForm";
// import PositionsTable from "@/components/PositionsTable";

const DashboardPage = () => {
  return (
    <Container maxWidth="xl" sx={{ py: 4 }}>
      <Box sx={{ mt: 4 }}>
        <Box sx={{ display: "flex", alignItems: "center", gap: 2, mb: 3 }}>
          <RateSwapForm />
        </Box>
        <Box sx={{ display: "flex", alignItems: "center", gap: 2, mb: 3 }}>
          <Typography variant="h5">Your Swap Positions</Typography>
        </Box>
        {/* <PositionsTable /> */}
      </Box>
    </Container>
  );
};

export default DashboardPage;
