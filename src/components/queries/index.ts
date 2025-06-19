//@todo this is hardcoded for now, but we can make it dynamic later
export const GET_SWAP_CREATEDS = `query Query {
  allSwapCreateds {
    nodes {
      swapId
      floatingPayer
      fixedPayer
    }
  }
}`;