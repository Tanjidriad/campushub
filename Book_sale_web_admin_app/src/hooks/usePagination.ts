import { useState, useCallback } from 'react'

export function usePagination(initialPage = 1, initialLimit = 10) {
  const [page, setPage] = useState(initialPage)
  const [limit] = useState(initialLimit)

  const nextPage = useCallback(() => setPage((p) => p + 1), [])
  const prevPage = useCallback(() => setPage((p) => Math.max(1, p - 1)), [])
  const goToPage = useCallback((p: number) => setPage(Math.max(1, p)), [])
  const resetPage = useCallback(() => setPage(1), [])

  return { page, limit, nextPage, prevPage, goToPage, resetPage }
}
