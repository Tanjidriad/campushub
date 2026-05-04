import { useState, useEffect } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi } from '@/api/admin'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Skeleton } from '@/components/ui/skeleton'
import { toast } from 'sonner'
import {
  Plus, Trash2, Save, GraduationCap, BookOpen,
  ChevronDown, ChevronRight, GitBranch, Building2, Calendar,
} from 'lucide-react'
import type { EducationLevel, EducationStream, EducationDepartment, BookType, SubLevel } from '@/types'

export default function EducationConfigPage() {
  const queryClient = useQueryClient()

  const [levels, setLevels] = useState<EducationLevel[]>([])
  const [bookTypes, setBookTypes] = useState<BookType[]>([])
  const [hasChanges, setHasChanges] = useState(false)
  const [expandedStreams, setExpandedStreams] = useState<Record<string, boolean>>({})

  const { data, isLoading } = useQuery({
    queryKey: ['education-config'],
    queryFn: adminApi.getEducationConfig,
  })

  useEffect(() => {
    if (data) {
      setLevels(data.levels)
      setBookTypes(data.bookTypes)
      setHasChanges(false)
    }
  }, [data])

  const saveMutation = useMutation({
    mutationFn: () => adminApi.updateEducationConfig({ levels, bookTypes }),
    onSuccess: () => {
      toast.success('Education config saved')
      queryClient.invalidateQueries({ queryKey: ['education-config'] })
      setHasChanges(false)
    },
    onError: (err: unknown) => {
      const error = err as { response?: { data?: { message?: string } } }
      toast.error(error.response?.data?.message || 'Failed to save')
    },
  })

  const markChanged = () => setHasChanges(true)

  // ─── Level helpers ───
  const addLevel = () => {
    setLevels([...levels, { key: '', label: '', subLevels: [], streams: [] }])
    markChanged()
  }

  const updateLevel = (idx: number, field: 'key' | 'label', value: string) => {
    const next = [...levels]
    next[idx] = { ...next[idx], [field]: value }
    setLevels(next)
    markChanged()
  }

  const removeLevel = (idx: number) => {
    setLevels(levels.filter((_, i) => i !== idx))
    markChanged()
  }

  // ─── SubLevel helpers (flat, for School-style) ───
  const addSubLevel = (levelIdx: number) => {
    const next = [...levels]
    next[levelIdx] = {
      ...next[levelIdx],
      subLevels: [...next[levelIdx].subLevels, { key: '', label: '' }],
    }
    setLevels(next)
    markChanged()
  }

  const updateSubLevel = (levelIdx: number, subIdx: number, field: 'key' | 'label', value: string) => {
    const next = [...levels]
    const subs = [...next[levelIdx].subLevels]
    subs[subIdx] = { ...subs[subIdx], [field]: value }
    next[levelIdx] = { ...next[levelIdx], subLevels: subs }
    setLevels(next)
    markChanged()
  }

  const removeSubLevel = (levelIdx: number, subIdx: number) => {
    const next = [...levels]
    next[levelIdx] = {
      ...next[levelIdx],
      subLevels: next[levelIdx].subLevels.filter((_, i) => i !== subIdx),
    }
    setLevels(next)
    markChanged()
  }

  // ─── Stream helpers ───
  const addStream = (levelIdx: number) => {
    const next = [...levels]
    const streams = [...(next[levelIdx].streams || [])]
    streams.push({ key: '', label: '', departments: [] })
    next[levelIdx] = { ...next[levelIdx], streams }
    setLevels(next)
    markChanged()
  }

  const updateStream = (levelIdx: number, streamIdx: number, field: 'key' | 'label', value: string) => {
    const next = [...levels]
    const streams = [...(next[levelIdx].streams || [])]
    streams[streamIdx] = { ...streams[streamIdx], [field]: value }
    next[levelIdx] = { ...next[levelIdx], streams }
    setLevels(next)
    markChanged()
  }

  const removeStream = (levelIdx: number, streamIdx: number) => {
    const next = [...levels]
    const streams = (next[levelIdx].streams || []).filter((_, i) => i !== streamIdx)
    next[levelIdx] = { ...next[levelIdx], streams }
    setLevels(next)
    markChanged()
  }

  // ─── Department helpers ───
  const addDepartment = (levelIdx: number, streamIdx: number) => {
    const next = [...levels]
    const streams = [...(next[levelIdx].streams || [])]
    const depts = [...streams[streamIdx].departments]
    depts.push({ key: '', label: '', subLevels: [] })
    streams[streamIdx] = { ...streams[streamIdx], departments: depts }
    next[levelIdx] = { ...next[levelIdx], streams }
    setLevels(next)
    markChanged()
  }

  const updateDepartment = (
    levelIdx: number, streamIdx: number, deptIdx: number,
    field: 'key' | 'label', value: string,
  ) => {
    const next = [...levels]
    const streams = [...(next[levelIdx].streams || [])]
    const depts = [...streams[streamIdx].departments]
    depts[deptIdx] = { ...depts[deptIdx], [field]: value }
    streams[streamIdx] = { ...streams[streamIdx], departments: depts }
    next[levelIdx] = { ...next[levelIdx], streams }
    setLevels(next)
    markChanged()
  }

  const removeDepartment = (levelIdx: number, streamIdx: number, deptIdx: number) => {
    const next = [...levels]
    const streams = [...(next[levelIdx].streams || [])]
    const depts = streams[streamIdx].departments.filter((_, i) => i !== deptIdx)
    streams[streamIdx] = { ...streams[streamIdx], departments: depts }
    next[levelIdx] = { ...next[levelIdx], streams }
    setLevels(next)
    markChanged()
  }

  // ─── Department SubLevel (semester) helpers ───
  const addDeptSubLevel = (levelIdx: number, streamIdx: number, deptIdx: number) => {
    const next = [...levels]
    const streams = [...(next[levelIdx].streams || [])]
    const depts = [...streams[streamIdx].departments]
    const subs = [...depts[deptIdx].subLevels, { key: '', label: '' }]
    depts[deptIdx] = { ...depts[deptIdx], subLevels: subs }
    streams[streamIdx] = { ...streams[streamIdx], departments: depts }
    next[levelIdx] = { ...next[levelIdx], streams }
    setLevels(next)
    markChanged()
  }

  const updateDeptSubLevel = (
    levelIdx: number, streamIdx: number, deptIdx: number, subIdx: number,
    field: 'key' | 'label', value: string,
  ) => {
    const next = [...levels]
    const streams = [...(next[levelIdx].streams || [])]
    const depts = [...streams[streamIdx].departments]
    const subs = [...depts[deptIdx].subLevels]
    subs[subIdx] = { ...subs[subIdx], [field]: value }
    depts[deptIdx] = { ...depts[deptIdx], subLevels: subs }
    streams[streamIdx] = { ...streams[streamIdx], departments: depts }
    next[levelIdx] = { ...next[levelIdx], streams }
    setLevels(next)
    markChanged()
  }

  const removeDeptSubLevel = (levelIdx: number, streamIdx: number, deptIdx: number, subIdx: number) => {
    const next = [...levels]
    const streams = [...(next[levelIdx].streams || [])]
    const depts = [...streams[streamIdx].departments]
    const subs = depts[deptIdx].subLevels.filter((_, i) => i !== subIdx)
    depts[deptIdx] = { ...depts[deptIdx], subLevels: subs }
    streams[streamIdx] = { ...streams[streamIdx], departments: depts }
    next[levelIdx] = { ...next[levelIdx], streams }
    setLevels(next)
    markChanged()
  }

  // ─── Book type helpers ───
  const addBookType = () => {
    setBookTypes([...bookTypes, { key: '', label: '' }])
    markChanged()
  }

  const updateBookType = (idx: number, field: 'key' | 'label', value: string) => {
    const next = [...bookTypes]
    next[idx] = { ...next[idx], [field]: value }
    setBookTypes(next)
    markChanged()
  }

  const removeBookType = (idx: number) => {
    setBookTypes(bookTypes.filter((_, i) => i !== idx))
    markChanged()
  }

  // ─── Toggle stream expand ───
  const toggleStream = (key: string) => {
    setExpandedStreams((prev) => ({ ...prev, [key]: !prev[key] }))
  }

  // ─── Validation + Save ───
  const handleSave = () => {
    const emptyLevel = levels.find((l) => !l.key.trim() || !l.label.trim())
    if (emptyLevel) {
      toast.error('All education levels need both a key and label')
      return
    }
    const emptySub = levels.find((l) => l.subLevels.some((s) => !s.key.trim() || !s.label.trim()))
    if (emptySub) {
      toast.error('All sub-levels need both a key and label')
      return
    }
    for (const level of levels) {
      for (const stream of (level.streams || [])) {
        if (!stream.key.trim() || !stream.label.trim()) {
          toast.error('All streams need both a key and label')
          return
        }
        for (const dept of stream.departments) {
          if (!dept.key.trim() || !dept.label.trim()) {
            toast.error('All departments need both a key and label')
            return
          }
          const emptySem = dept.subLevels.find((s) => !s.key.trim() || !s.label.trim())
          if (emptySem) {
            toast.error(`Department "${dept.label || dept.key}" has empty semesters`)
            return
          }
        }
      }
    }
    const emptyBt = bookTypes.find((b) => !b.key.trim() || !b.label.trim())
    if (emptyBt) {
      toast.error('All book types need both a key and label')
      return
    }
    saveMutation.mutate()
  }

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-10 w-60" />
        <Skeleton className="h-64" />
        <Skeleton className="h-48" />
      </div>
    )
  }

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold">Education Configuration</h2>
          <p className="text-sm text-[hsl(var(--muted-foreground))]">
            Manage education levels, streams, departments and book types
          </p>
        </div>
        <Button onClick={handleSave} disabled={!hasChanges || saveMutation.isPending}>
          <Save className="mr-2 h-4 w-4" />
          {saveMutation.isPending ? 'Saving...' : 'Save All Changes'}
        </Button>
      </div>

      {hasChanges && (
        <div className="animate-fade-in rounded-xl border border-[hsl(var(--warning))] bg-[hsl(var(--warning)/0.1)] p-4 text-sm text-[hsl(var(--warning))] flex items-center gap-3">
          <div className="h-2 w-2 rounded-full bg-[hsl(var(--warning))] animate-pulse" />
          You have unsaved changes. Click "Save All Changes" to apply them.
        </div>
      )}

      {/* Education Levels */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle className="flex items-center gap-2 text-base">
              <GraduationCap className="h-5 w-5" /> Education Levels ({levels.length})
            </CardTitle>
            <Button size="sm" onClick={addLevel}>
              <Plus className="mr-1 h-3 w-3" /> Add Level
            </Button>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          {levels.length === 0 && (
            <p className="py-4 text-center text-sm text-[hsl(var(--muted-foreground))]">
              No education levels defined. Click "Add Level" to start.
            </p>
          )}
          {levels.map((level, levelIdx) => (
            <div key={levelIdx} className="rounded-lg border p-4 space-y-3">
              {/* Level key/label */}
              <div className="flex items-center gap-3">
                <div className="flex-1">
                  <label className="text-xs font-medium text-[hsl(var(--muted-foreground))]">Key</label>
                  <Input
                    value={level.key}
                    onChange={(e) => updateLevel(levelIdx, 'key', e.target.value)}
                    placeholder="e.g. university"
                  />
                </div>
                <div className="flex-1">
                  <label className="text-xs font-medium text-[hsl(var(--muted-foreground))]">Label</label>
                  <Input
                    value={level.label}
                    onChange={(e) => updateLevel(levelIdx, 'label', e.target.value)}
                    placeholder="e.g. University"
                  />
                </div>
                <Button
                  variant="ghost"
                  size="sm"
                  className="mt-5 text-red-600 hover:text-red-700"
                  onClick={() => removeLevel(levelIdx)}
                >
                  <Trash2 className="h-4 w-4" />
                </Button>
              </div>

              {/* Flat Sub-levels */}
              <div className="ml-6 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-medium text-[hsl(var(--muted-foreground))]">
                    Sub-levels ({level.subLevels.length})
                  </span>
                  <Button variant="ghost" size="sm" onClick={() => addSubLevel(levelIdx)}>
                    <Plus className="mr-1 h-3 w-3" /> Add
                  </Button>
                </div>
                {level.subLevels.map((sub, subIdx) => (
                  <div key={subIdx} className="flex items-center gap-2">
                    <Input
                      className="h-8 text-sm"
                      value={sub.key}
                      onChange={(e) => updateSubLevel(levelIdx, subIdx, 'key', e.target.value)}
                      placeholder="key"
                    />
                    <Input
                      className="h-8 text-sm"
                      value={sub.label}
                      onChange={(e) => updateSubLevel(levelIdx, subIdx, 'label', e.target.value)}
                      placeholder="label"
                    />
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8 text-red-600 hover:text-red-700"
                      onClick={() => removeSubLevel(levelIdx, subIdx)}
                    >
                      <Trash2 className="h-3 w-3" />
                    </Button>
                  </div>
                ))}
              </div>

              {/* Streams (nested hierarchy) */}
              <div className="ml-6 mt-3 space-y-3 border-t pt-3">
                <div className="flex items-center justify-between">
                  <span className="flex items-center gap-1.5 text-xs font-medium text-blue-600">
                    <GitBranch className="h-3.5 w-3.5" />
                    Streams ({(level.streams || []).length})
                  </span>
                  <Button variant="ghost" size="sm" className="text-blue-600 hover:text-blue-700" onClick={() => addStream(levelIdx)}>
                    <Plus className="mr-1 h-3 w-3" /> Add Stream
                  </Button>
                </div>

                {(level.streams || []).map((stream, streamIdx) => {
                  const streamKey = `${levelIdx}-${streamIdx}`
                  const isExpanded = expandedStreams[streamKey] ?? true
                  return (
                    <div key={streamIdx} className="rounded-md border border-blue-200 dark:border-blue-900 bg-blue-50/30 dark:bg-blue-950/20 p-3 space-y-2">
                      <div className="flex items-center gap-2">
                        <button
                          type="button"
                          onClick={() => toggleStream(streamKey)}
                          className="text-blue-600 hover:text-blue-800"
                        >
                          {isExpanded ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
                        </button>
                        <Input
                          className="h-8 text-sm flex-1"
                          value={stream.key}
                          onChange={(e) => updateStream(levelIdx, streamIdx, 'key', e.target.value)}
                          placeholder="stream key"
                        />
                        <Input
                          className="h-8 text-sm flex-1"
                          value={stream.label}
                          onChange={(e) => updateStream(levelIdx, streamIdx, 'label', e.target.value)}
                          placeholder="stream label"
                        />
                        <span className="text-xs text-[hsl(var(--muted-foreground))] whitespace-nowrap">
                          {stream.departments.length} dept
                        </span>
                        <Button
                          variant="ghost"
                          size="icon"
                          className="h-7 w-7 text-red-600 hover:text-red-700"
                          onClick={() => removeStream(levelIdx, streamIdx)}
                        >
                          <Trash2 className="h-3 w-3" />
                        </Button>
                      </div>

                      {isExpanded && (
                        <div className="ml-7 space-y-2">
                          <div className="flex items-center justify-between">
                            <span className="flex items-center gap-1.5 text-xs font-medium text-emerald-600">
                              <Building2 className="h-3 w-3" />
                              Departments ({stream.departments.length})
                            </span>
                            <Button
                              variant="ghost"
                              size="sm"
                              className="text-emerald-600 hover:text-emerald-700 h-7 text-xs"
                              onClick={() => addDepartment(levelIdx, streamIdx)}
                            >
                              <Plus className="mr-1 h-3 w-3" /> Add Dept
                            </Button>
                          </div>

                          {stream.departments.map((dept, deptIdx) => (
                            <div key={deptIdx} className="rounded border bg-white dark:bg-[hsl(var(--card))] p-2.5 space-y-2">
                              <div className="flex items-center gap-2">
                                <Input
                                  className="h-7 text-xs flex-1"
                                  value={dept.key}
                                  onChange={(e) => updateDepartment(levelIdx, streamIdx, deptIdx, 'key', e.target.value)}
                                  placeholder="dept key (e.g. cse)"
                                />
                                <Input
                                  className="h-7 text-xs flex-1"
                                  value={dept.label}
                                  onChange={(e) => updateDepartment(levelIdx, streamIdx, deptIdx, 'label', e.target.value)}
                                  placeholder="dept label (e.g. CSE)"
                                />
                                <Button
                                  variant="ghost"
                                  size="icon"
                                  className="h-6 w-6 text-red-500 hover:text-red-600"
                                  onClick={() => removeDepartment(levelIdx, streamIdx, deptIdx)}
                                >
                                  <Trash2 className="h-3 w-3" />
                                </Button>
                              </div>

                              {/* Semesters */}
                              <div className="ml-4 space-y-1">
                                <div className="flex items-center justify-between">
                                  <span className="flex items-center gap-1 text-[10px] font-medium text-amber-600">
                                    <Calendar className="h-3 w-3" />
                                    Semesters ({dept.subLevels.length})
                                  </span>
                                  <Button
                                    variant="ghost"
                                    size="sm"
                                    className="text-amber-600 hover:text-amber-700 h-6 text-[10px] px-2"
                                    onClick={() => addDeptSubLevel(levelIdx, streamIdx, deptIdx)}
                                  >
                                    <Plus className="mr-0.5 h-2.5 w-2.5" /> Add
                                  </Button>
                                </div>
                                {dept.subLevels.length > 0 && (
                                  <div className="flex flex-wrap gap-1.5">
                                    {dept.subLevels.map((sem, semIdx) => (
                                      <div key={semIdx} className="flex items-center gap-1 rounded border border-amber-200 dark:border-amber-900 bg-amber-50 dark:bg-amber-950/30 px-2 py-0.5">
                                        <input
                                          className="w-14 bg-transparent text-[10px] outline-none"
                                          value={sem.key}
                                          onChange={(e) => updateDeptSubLevel(levelIdx, streamIdx, deptIdx, semIdx, 'key', e.target.value)}
                                          placeholder="key"
                                        />
                                        <input
                                          className="w-16 bg-transparent text-[10px] outline-none"
                                          value={sem.label}
                                          onChange={(e) => updateDeptSubLevel(levelIdx, streamIdx, deptIdx, semIdx, 'label', e.target.value)}
                                          placeholder="label"
                                        />
                                        <button
                                          type="button"
                                          className="text-red-400 hover:text-red-600"
                                          onClick={() => removeDeptSubLevel(levelIdx, streamIdx, deptIdx, semIdx)}
                                        >
                                          <Trash2 className="h-2.5 w-2.5" />
                                        </button>
                                      </div>
                                    ))}
                                  </div>
                                )}
                              </div>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  )
                })}
              </div>
            </div>
          ))}
        </CardContent>
      </Card>

      {/* Book Types */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle className="flex items-center gap-2 text-base">
              <BookOpen className="h-5 w-5" /> Book Types ({bookTypes.length})
            </CardTitle>
            <Button size="sm" onClick={addBookType}>
              <Plus className="mr-1 h-3 w-3" /> Add Type
            </Button>
          </div>
        </CardHeader>
        <CardContent className="space-y-2">
          {bookTypes.length === 0 && (
            <p className="py-4 text-center text-sm text-[hsl(var(--muted-foreground))]">
              No book types defined. Click "Add Type" to start.
            </p>
          )}
          {bookTypes.map((bt, idx) => (
            <div key={idx} className="flex items-center gap-3">
              <div className="flex-1">
                <Input
                  value={bt.key}
                  onChange={(e) => updateBookType(idx, 'key', e.target.value)}
                  placeholder="key (e.g. textbook)"
                />
              </div>
              <div className="flex-1">
                <Input
                  value={bt.label}
                  onChange={(e) => updateBookType(idx, 'label', e.target.value)}
                  placeholder="label (e.g. Textbook)"
                />
              </div>
              <Button
                variant="ghost"
                size="sm"
                className="text-red-600 hover:text-red-700"
                onClick={() => removeBookType(idx)}
              >
                <Trash2 className="h-4 w-4" />
              </Button>
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  )
}
