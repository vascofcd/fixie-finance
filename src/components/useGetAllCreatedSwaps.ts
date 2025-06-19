import { useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import { GET_SWAP_CREATEDS } from './queries';

const GRAPHQL_ENDPOINT = '/api/graphql';

export const useGetAllCreatedSwaps = () => {
  const { data, isLoading, error } = useQuery({
    queryKey: ['swapCreateds'],
    queryFn: async () => {
      const response = await fetch(GRAPHQL_ENDPOINT, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          query: GET_SWAP_CREATEDS,
        }),
      })

      if (!response.ok) {
        throw new Error("Network response was not ok")
      }

      return response.json()
    },
  });

  const swapCreateds = useMemo(() => {
    if (!data) return [];

    const pos = new Set<string>();

    data.data.allSwapCreateds.nodes.forEach(item => {
      if (item.swapId) {
        pos.add(`${item.swapId}`)
      }
    });

    return data.data.allSwapCreateds.nodes
  }, [data]);

  return { swapCreateds, isLoading, error };
};