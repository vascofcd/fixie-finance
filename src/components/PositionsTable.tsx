// import {
//   Table,
//   TableBody,
//   TableCell,
//   TableContainer,
//   TableHead,
//   TableRow,
//   Button,
//   Chip,
// } from "@mui/material";
// import { Position } from "./types";
// import { useGetAllCreatedSwaps } from "./useGetAllCreatedSwaps";

// const PositionsTable: React.FC = () => {
//   const { swapCreateds, isLoading, error } = useGetAllCreatedSwaps();

//   if (isLoading) return <p>Loading...</p>;
//   if (error) return <p>Error: {error.message}</p>;

//   return (
//     <TableContainer>
//       <Table>
//         <TableHead>
//           <TableRow sx={{ background: "rgba(245, 243, 249, 0.5)" }}>
//             <TableCell sx={{ fontWeight: 600, color: "#7a7a9d" }}>
//               Position ID
//             </TableCell>
//             <TableCell sx={{ fontWeight: 600, color: "#7a7a9d" }}>
//               Notional
//             </TableCell>
//             <TableCell sx={{ fontWeight: 600, color: "#7a7a9d" }}>
//               Fixed Rate
//             </TableCell>
//             <TableCell sx={{ fontWeight: 600, color: "#7a7a9d" }}>
//               Variable Rate
//             </TableCell>
//             <TableCell sx={{ fontWeight: 600, color: "#7a7a9d" }}>
//               Duration
//             </TableCell>
//             <TableCell sx={{ fontWeight: 600, color: "#7a7a9d" }}>
//               Value
//             </TableCell>
//             <TableCell sx={{ fontWeight: 600, color: "#7a7a9d" }}>
//               Status
//             </TableCell>
//             <TableCell sx={{ fontWeight: 600, color: "#7a7a9d" }}>
//               Action
//             </TableCell>
//           </TableRow>
//         </TableHead>
//         <TableBody>
//           {!!swapCreateds &&
//             swapCreateds.map((position) => (
//               <TableRow key={position.id} hover>
//                 <TableCell sx={{ fontWeight: 500 }}>{position.id}</TableCell>
//                 <TableCell sx={{ fontWeight: 500 }}>
//                   {position.notional}
//                 </TableCell>
//                 <TableCell>{position.fixedRate}</TableCell>
//                 <TableCell>{position.variableRate}</TableCell>
//                 <TableCell>{position.duration}</TableCell>
//                 <TableCell
//                   sx={{
//                     color: position.value.startsWith("+")
//                       ? "#7fd1b9"
//                       : "#ff8a8a",
//                     fontWeight: 500,
//                   }}
//                 >
//                   {position.value}
//                 </TableCell>
//                 <TableCell>
//                   <Chip
//                     label={
//                       position.status === "active" ? "Active" : "Completed"
//                     }
//                     size="small"
//                     sx={{
//                       background:
//                         position.status === "active"
//                           ? "rgba(127, 209, 185, 0.2)"
//                           : "rgba(197, 179, 230, 0.2)",
//                       color:
//                         position.status === "active" ? "#7fd1b9" : "#c5b3e6",
//                       fontWeight: 500,
//                     }}
//                   />
//                 </TableCell>
//                 <TableCell>
//                   <Button
//                     variant="outlined"
//                     size="small"
//                     sx={{
//                       borderRadius: "8px",
//                       borderColor: "#c5b3e6",
//                       color: "#c5b3e6",
//                       fontWeight: 500,
//                       "&:hover": {
//                         background: "rgba(197, 179, 230, 0.1)",
//                         borderColor: "#c5b3e6",
//                       },
//                     }}
//                   >
//                     {position.status === "completed" ? "View" : "Manage"}
//                   </Button>
//                 </TableCell>
//               </TableRow>
//             ))}
//         </TableBody>
//       </Table>
//     </TableContainer>
//   );
// };

// export default PositionsTable;
