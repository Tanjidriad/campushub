# Admin Listing Management Endpoints

## Overview
This document describes the newly implemented admin endpoints for comprehensive listing management in CampusHub Pro.

## New Endpoints Added

### 1. Get All Listings (Admin View)
**Endpoint:** `GET /api/admin/listings`

**Description:** Retrieve all listings with advanced search and filtering capabilities, plus statistics.

**Query Parameters:**
- `search` - Search by title, description, or listing ID
- `status` - Filter by status (pending/approved/rejected)
- `category` - Filter by category
- `priceType` - Filter by price type (sell/rent)
- `condition` - Filter by condition
- `isFeatured` - Filter featured listings (true/false)
- `minPrice` / `maxPrice` - Price range
- `sellerId` - Filter by specific seller
- `page` / `limit` - Pagination
- `sort` - Sort order (default: -createdAt)

**Response Includes:**
- Paginated listings with seller and admin details
- Statistics (total, pending, approved, rejected, featured counts)
- Top categories breakdown

### 2. Bulk Approve Listings
**Endpoint:** `POST /api/admin/listings/bulk-approve`

**Description:** Approve multiple listings at once.

**Request Body:**
```json
{
  "listingIds": ["id1", "id2", "id3"]
}
```

**Features:**
- Only approves pending listings
- Sends email notifications to sellers
- Creates in-app notifications
- Updates approval metadata (approvedBy, approvedAt)

### 3. Bulk Reject Listings
**Endpoint:** `POST /api/admin/listings/bulk-reject`

**Description:** Reject multiple listings at once with a common reason.

**Request Body:**
```json
{
  "listingIds": ["id1", "id2", "id3"],
  "reason": "Policy violation"
}
```

**Features:**
- Only rejects pending listings
- Sends email notifications with rejection reason
- Creates in-app notifications

### 4. Bulk Delete Listings
**Endpoint:** `POST /api/admin/listings/bulk-delete`

**Description:** Permanently delete multiple listings and their images.

**Request Body:**
```json
{
  "listingIds": ["id1", "id2", "id3"]
}
```

**Features:**
- Deletes listings from database
- Removes all associated images from Cloudinary
- Can delete listings of any status

## Testing the Endpoints

### Prerequisites
1. Server running on `http://localhost:5000`
2. Admin user credentials:
   - Email: Create an admin user or use existing
   - You need a valid JWT token with admin role

### Using Postman Collection
The endpoints are included in the existing `CampusHub_Pro.postman_collection.json`.

### Manual Testing with cURL

#### 1. Get All Listings
```bash
curl -X GET "http://localhost:5000/api/admin/listings?page=1&limit=10" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

#### 2. Search Listings
```bash
curl -X GET "http://localhost:5000/api/admin/listings?search=textbook&status=approved" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

#### 3. Bulk Approve
```bash
curl -X POST "http://localhost:5000/api/admin/listings/bulk-approve" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "listingIds": ["listing_id_1", "listing_id_2"]
  }'
```

#### 4. Bulk Reject
```bash
curl -X POST "http://localhost:5000/api/admin/listings/bulk-reject" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "listingIds": ["listing_id_1", "listing_id_2"],
    "reason": "Violates content policy"
  }'
```

#### 5. Bulk Delete
```bash
curl -X POST "http://localhost:5000/api/admin/listings/bulk-delete" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "listingIds": ["listing_id_1", "listing_id_2"]
  }'
```

## Frontend Integration

### Flutter Admin App Usage

#### 1. Fetch All Listings with Filters
```dart
// In your repository/service class
Future<ListingsResponse> getAllListings({
  int page = 1,
  int limit = 10,
  String? search,
  String? status,
  String? category,
  bool? isFeatured,
}) async {
  final queryParams = {
    'page': page.toString(),
    'limit': limit.toString(),
    if (search != null) 'search': search,
    if (status != null) 'status': status,
    if (category != null) 'category': category,
    if (isFeatured != null) 'isFeatured': isFeatured.toString(),
  };
  
  final response = await dio.get(
    '/admin/listings',
    queryParameters: queryParams,
  );
  
  return ListingsResponse.fromJson(response.data);
}
```

#### 2. Bulk Approve
```dart
Future<BulkActionResponse> bulkApprove(List<String> listingIds) async {
  final response = await dio.post(
    '/admin/listings/bulk-approve',
    data: {'listingIds': listingIds},
  );
  
  return BulkActionResponse.fromJson(response.data);
}
```

#### 3. Bulk Reject
```dart
Future<BulkActionResponse> bulkReject(
  List<String> listingIds,
  String reason,
) async {
  final response = await dio.post(
    '/admin/listings/bulk-reject',
    data: {
      'listingIds': listingIds,
      'reason': reason,
    },
  );
  
  return BulkActionResponse.fromJson(response.data);
}
```

#### 4. Bulk Delete
```dart
Future<BulkActionResponse> bulkDelete(List<String> listingIds) async {
  final response = await dio.post(
    '/admin/listings/bulk-delete',
    data: {'listingIds': listingIds},
  );
  
  return BulkActionResponse.fromJson(response.data);
}
```

## Response Models

### ListingsResponse Model
```dart
class ListingsResponse {
  final bool success;
  final List<Listing> data;
  final Pagination pagination;
  final ListingStatistics statistics;

  ListingsResponse({
    required this.success,
    required this.data,
    required this.pagination,
    required this.statistics,
  });

  factory ListingsResponse.fromJson(Map<String, dynamic> json) {
    return ListingsResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List)
          .map((e) => Listing.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
      statistics: ListingStatistics.fromJson(json['statistics']),
    );
  }
}
```

### ListingStatistics Model
```dart
class ListingStatistics {
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final int featured;
  final List<CategoryCount> topCategories;

  ListingStatistics({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.featured,
    required this.topCategories,
  });

  factory ListingStatistics.fromJson(Map<String, dynamic> json) {
    return ListingStatistics(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
      featured: json['featured'] ?? 0,
      topCategories: (json['topCategories'] as List?)
          ?.map((e) => CategoryCount.fromJson(e))
          .toList() ?? [],
    );
  }
}

class CategoryCount {
  final String id;
  final int count;

  CategoryCount({required this.id, required this.count});

  factory CategoryCount.fromJson(Map<String, dynamic> json) {
    return CategoryCount(
      id: json['_id'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
```

### BulkActionResponse Model
```dart
class BulkActionResponse {
  final bool success;
  final String message;
  final int count;

  BulkActionResponse({
    required this.success,
    required this.message,
    required this.count,
  });

  factory BulkActionResponse.fromJson(Map<String, dynamic> json) {
    return BulkActionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      count: json['data']?['count'] ?? 0,
    );
  }
}
```

## Error Handling

All endpoints return standard error responses:

```json
{
  "success": false,
  "message": "Error description"
}
```

Common errors:
- **400 Bad Request** - Invalid input (e.g., empty array, missing reason)
- **401 Unauthorized** - Missing or invalid token
- **403 Forbidden** - Insufficient permissions (not admin)
- **404 Not Found** - No listings found matching criteria
- **500 Internal Server Error** - Server error

## Security Notes

1. All endpoints require authentication with admin role
2. Bulk actions only affect listings that match the expected status
3. Email notifications are sent asynchronously
4. Image deletion from Cloudinary happens before database deletion
5. All actions are logged with admin user ID

## Performance Considerations

1. Bulk operations are executed in parallel using `Promise.all()`
2. Statistics are calculated using MongoDB aggregation pipeline
3. Database queries use indexes on commonly filtered fields
4. Pagination limits maximum results per request

## Next Steps

- [ ] Implement rate limiting for bulk operations
- [ ] Add audit logging for admin actions
- [ ] Create admin activity dashboard
- [ ] Add export functionality (CSV/Excel)
- [ ] Implement scheduled listing cleanup
