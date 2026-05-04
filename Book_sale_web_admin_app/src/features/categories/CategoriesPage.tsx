import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { categoryApi } from '@/api/admin'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'
import { Skeleton } from '@/components/ui/skeleton'
import { toast } from 'sonner'
import { Plus, Edit, Trash2, ToggleLeft, ToggleRight, FolderOpen, BookOpen } from 'lucide-react'
import type { Category } from '@/types'

export default function CategoriesPage() {
  const queryClient = useQueryClient()

  const [createDialog, setCreateDialog] = useState(false)
  const [editDialog, setEditDialog] = useState<{ open: boolean; category: Category | null }>({
    open: false, category: null,
  })
  const [deleteDialog, setDeleteDialog] = useState<{ open: boolean; id: string; name: string }>({
    open: false, id: '', name: '',
  })

  // Form state
  const [formName, setFormName] = useState('')
  const [formDescription, setFormDescription] = useState('')
  const [formIcon, setFormIcon] = useState('category')
  const [formOrder, setFormOrder] = useState(0)
  const [formImage, setFormImage] = useState<File | null>(null)
  const [formHasEducationConfig, setFormHasEducationConfig] = useState(false)

  const { data: categories, isLoading } = useQuery({
    queryKey: ['categories'],
    queryFn: () => categoryApi.getAll(true),
  })

  const createMutation = useMutation({
    mutationFn: (formData: FormData) => categoryApi.create(formData),
    onSuccess: () => {
      toast.success('Category created')
      queryClient.invalidateQueries({ queryKey: ['categories'] })
      closeCreate()
    },
    onError: (err: unknown) => {
      const error = err as { response?: { data?: { message?: string } } }
      toast.error(error.response?.data?.message || 'Failed to create category')
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, formData }: { id: string; formData: FormData }) => categoryApi.update(id, formData),
    onSuccess: () => {
      toast.success('Category updated')
      queryClient.invalidateQueries({ queryKey: ['categories'] })
      setEditDialog({ open: false, category: null })
    },
    onError: (err: unknown) => {
      const error = err as { response?: { data?: { message?: string } } }
      toast.error(error.response?.data?.message || 'Failed to update category')
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => categoryApi.delete(id),
    onSuccess: () => {
      toast.success('Category deleted')
      queryClient.invalidateQueries({ queryKey: ['categories'] })
      setDeleteDialog({ open: false, id: '', name: '' })
    },
    onError: (err: unknown) => {
      const error = err as { response?: { data?: { message?: string } } }
      toast.error(error.response?.data?.message || 'Cannot delete - category has listings')
    },
  })

  const toggleMutation = useMutation({
    mutationFn: (id: string) => categoryApi.toggle(id),
    onSuccess: () => {
      toast.success('Status toggled')
      queryClient.invalidateQueries({ queryKey: ['categories'] })
    },
    onError: () => toast.error('Failed to toggle'),
  })

  const resetForm = () => {
    setFormName('')
    setFormDescription('')
    setFormIcon('category')
    setFormOrder(0)
    setFormImage(null)
    setFormHasEducationConfig(false)
  }

  const closeCreate = () => {
    setCreateDialog(false)
    resetForm()
  }

  const openEdit = (cat: Category) => {
    setFormName(cat.name)
    setFormDescription(cat.description || '')
    setFormIcon(cat.icon)
    setFormOrder(cat.displayOrder)
    setFormImage(null)
    setFormHasEducationConfig(cat.hasEducationConfig ?? false)
    setEditDialog({ open: true, category: cat })
  }

  const buildFormData = () => {
    const fd = new FormData()
    fd.append('name', formName)
    fd.append('description', formDescription)
    fd.append('icon', formIcon)
    fd.append('displayOrder', String(formOrder))
    fd.append('hasEducationConfig', String(formHasEducationConfig))
    if (formImage) fd.append('image', formImage)
    return fd
  }

  const handleCreate = () => {
    if (!formName.trim()) {
      toast.error('Name is required')
      return
    }
    createMutation.mutate(buildFormData())
  }

  const handleUpdate = () => {
    if (!editDialog.category || !formName.trim()) return
    updateMutation.mutate({ id: editDialog.category._id, formData: buildFormData() })
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold">Categories ({categories?.length ?? 0})</h2>
          <p className="text-sm text-[hsl(var(--muted-foreground))]">Manage book categories</p>
        </div>
        <Button onClick={() => { resetForm(); setCreateDialog(true) }}>
          <Plus className="mr-2 h-4 w-4" />
          Add Category
        </Button>
      </div>

      {isLoading ? (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {Array.from({ length: 6 }).map((_, i) => (
            <Skeleton key={i} className="h-40" />
          ))}
        </div>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3 stagger-children">
          {categories?.map((cat) => (
            <Card key={cat._id} className={`group transition-all duration-300 ${!cat.isActive ? 'opacity-60 grayscale' : 'hover:shadow-lg'}`}>
              <CardHeader className="pb-3">
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-3">
                    {cat.image ? (
                      <img src={cat.image} alt={cat.name} className="h-12 w-12 rounded-xl object-cover transition-transform group-hover:scale-110" />
                    ) : (
                      <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-[hsl(var(--primary)/0.1)] transition-transform group-hover:scale-110">
                        <FolderOpen className="h-6 w-6" />
                      </div>
                    )}
                    <div>
                      <CardTitle className="text-base">{cat.name}</CardTitle>
                      <p className="text-xs text-[hsl(var(--muted-foreground))]">/{cat.slug}</p>
                    </div>
                  </div>
                  <Badge variant={cat.isActive ? 'success' : 'secondary'}>
                    {cat.isActive ? 'Active' : 'Inactive'}
                  </Badge>
                </div>
              </CardHeader>
              <CardContent>
                {cat.description && (
                  <p className="mb-3 text-sm text-[hsl(var(--muted-foreground))]">{cat.description}</p>
                )}
                <div className="flex items-center gap-4 text-sm text-[hsl(var(--muted-foreground))]">
                  <span className="flex items-center gap-1">
                    <BookOpen className="h-4 w-4" /> {cat.listingCount} listings
                  </span>
                  <span>Order: {cat.displayOrder}</span>
                </div>
                <div className="mt-4 flex gap-2">
                  <Button variant="outline" size="sm" onClick={() => openEdit(cat)}>
                    <Edit className="mr-1 h-3 w-3" /> Edit
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => toggleMutation.mutate(cat._id)}
                  >
                    {cat.isActive ? <ToggleRight className="mr-1 h-3 w-3" /> : <ToggleLeft className="mr-1 h-3 w-3" />}
                    {cat.isActive ? 'Disable' : 'Enable'}
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setDeleteDialog({ open: true, id: cat._id, name: cat.name })}
                  >
                    <Trash2 className="mr-1 h-3 w-3 text-red-600" /> Delete
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {/* Create Dialog */}
      <Dialog open={createDialog} onClose={closeCreate}>
        <DialogHeader>
          <DialogTitle>Create Category</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          <div>
            <label className="text-sm font-medium">Name *</label>
            <Input value={formName} onChange={(e) => setFormName(e.target.value)} placeholder="e.g. Textbooks" />
          </div>
          <div>
            <label className="text-sm font-medium">Description</label>
            <Textarea value={formDescription} onChange={(e) => setFormDescription(e.target.value)} placeholder="Category description" rows={2} />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="text-sm font-medium">Icon</label>
              <Input value={formIcon} onChange={(e) => setFormIcon(e.target.value)} placeholder="category" />
            </div>
            <div>
              <label className="text-sm font-medium">Display Order</label>
              <Input type="number" value={formOrder} onChange={(e) => setFormOrder(Number(e.target.value))} />
            </div>
          </div>
          <div>
            <label className="text-sm font-medium">Image</label>
            <Input type="file" accept="image/*" onChange={(e) => setFormImage(e.target.files?.[0] ?? null)} />
          </div>
          <div className="flex items-center space-x-2 pt-2">
            <input
              type="checkbox"
              id="eduConfigCreate"
              checked={formHasEducationConfig}
              onChange={(e) => setFormHasEducationConfig(e.target.checked)}
              className="h-4 w-4 rounded border-gray-300"
            />
            <label htmlFor="eduConfigCreate" className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
              Requires Education Details (e.g. for Textbooks)
            </label>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={closeCreate}>Cancel</Button>
          <Button onClick={handleCreate} disabled={createMutation.isPending}>
            {createMutation.isPending ? 'Creating...' : 'Create'}
          </Button>
        </DialogFooter>
      </Dialog>

      {/* Edit Dialog */}
      <Dialog open={editDialog.open} onClose={() => setEditDialog({ open: false, category: null })}>
        <DialogHeader>
          <DialogTitle>Edit Category</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          <div>
            <label className="text-sm font-medium">Name *</label>
            <Input value={formName} onChange={(e) => setFormName(e.target.value)} />
          </div>
          <div>
            <label className="text-sm font-medium">Description</label>
            <Textarea value={formDescription} onChange={(e) => setFormDescription(e.target.value)} rows={2} />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="text-sm font-medium">Icon</label>
              <Input value={formIcon} onChange={(e) => setFormIcon(e.target.value)} />
            </div>
            <div>
              <label className="text-sm font-medium">Display Order</label>
              <Input type="number" value={formOrder} onChange={(e) => setFormOrder(Number(e.target.value))} />
            </div>
          </div>
          <div>
            <label className="text-sm font-medium">New Image (optional)</label>
            <Input type="file" accept="image/*" onChange={(e) => setFormImage(e.target.files?.[0] ?? null)} />
          </div>
          <div className="flex items-center space-x-2 pt-2">
            <input
              type="checkbox"
              id="eduConfigEdit"
              checked={formHasEducationConfig}
              onChange={(e) => setFormHasEducationConfig(e.target.checked)}
              className="h-4 w-4 rounded border-gray-300"
            />
            <label htmlFor="eduConfigEdit" className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
              Requires Education Details (e.g. for Textbooks)
            </label>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => setEditDialog({ open: false, category: null })}>Cancel</Button>
          <Button onClick={handleUpdate} disabled={updateMutation.isPending}>
            {updateMutation.isPending ? 'Saving...' : 'Save Changes'}
          </Button>
        </DialogFooter>
      </Dialog>

      {/* Delete Dialog */}
      <Dialog open={deleteDialog.open} onClose={() => setDeleteDialog({ ...deleteDialog, open: false })}>
        <DialogHeader>
          <DialogTitle>Delete Category</DialogTitle>
        </DialogHeader>
        <p className="text-sm text-[hsl(var(--muted-foreground))]">
          Delete "{deleteDialog.name}"? This will fail if the category has any listings.
        </p>
        <DialogFooter>
          <Button variant="outline" onClick={() => setDeleteDialog({ ...deleteDialog, open: false })}>Cancel</Button>
          <Button
            variant="destructive"
            onClick={() => deleteMutation.mutate(deleteDialog.id)}
            disabled={deleteMutation.isPending}
          >
            {deleteMutation.isPending ? 'Deleting...' : 'Delete'}
          </Button>
        </DialogFooter>
      </Dialog>
    </div>
  )
}
