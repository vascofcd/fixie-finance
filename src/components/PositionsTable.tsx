import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Button,
  Chip,
} from "@mui/material";
import { Position } from "./types";
import { useGetAllCreatedSwaps } from "./useGetAllCreatedSwaps";

const PositionsTable: React.FC = () => {
  const { swapCreateds, isLoading, error } = useGetAllCreatedSwaps();

  if (isLoading) return <p>Loading...</p>;
  if (error) return <p>Error: {error.message}</p>;

  return (
    <TableContainer>
      <Table>
        <TableHead>
          <TableRow sx={{ background: "rgba(245, 243, 249, 0.5)" }}>
            <TableCell sx={{ fontWeight: 600, color: "#7a7a9d" }}>
              Position ID
            </TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {!!swapCreateds &&
            swapCreateds.map((position) => (
              <TableRow key={position.swapId} hover>
                <TableCell sx={{ fontWeight: 500 }}>
                  {position.swapId}
                </TableCell>
              </TableRow>
            ))}
        </TableBody>
      </Table>
    </TableContainer>
  );
};

export default PositionsTable;
