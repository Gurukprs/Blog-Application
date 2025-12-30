# ActiveStorage Tables Analysis

## Overview
ActiveStorage uses three main tables to manage file attachments in Rails applications. This document explains the purpose of each table and how records are inserted when uploading images to posts.

## Table Structure

### 1. `active_storage_blobs`
**Purpose**: Stores metadata about uploaded files (blobs).

**Columns**:
- `key` (string, unique): A unique identifier for the file blob (UUID-based)
- `filename` (string): Original filename of the uploaded file
- `content_type` (string): MIME type of the file (e.g., "image/png", "image/jpeg")
- `metadata` (text): JSON metadata about the file (dimensions, analyzed info, etc.)
- `service_name` (string): Name of the storage service used (e.g., "local", "amazon", "google")
- `byte_size` (bigint): Size of the file in bytes
- `checksum` (string): MD5 checksum of the file content for integrity verification
- `created_at` (datetime): Timestamp when the blob was created

**Key Characteristics**:
- One blob record per unique file (based on checksum)
- Blobs are shared across attachments if the same file is uploaded multiple times
- The actual file is stored in the storage service (local disk, S3, etc.)

### 2. `active_storage_attachments`
**Purpose**: Polymorphic join table connecting records (like Post) to blobs.

**Columns**:
- `name` (string): The attachment name (e.g., "image", "avatar", "document")
- `record_type` (string): The model class name (e.g., "Post", "User")
- `record_id` (integer): The ID of the record that has the attachment
- `blob_id` (integer): Foreign key to `active_storage_blobs`
- `created_at` (datetime): Timestamp when the attachment was created

**Key Characteristics**:
- Polymorphic association allows any model to have attachments
- Unique constraint on `[record_type, record_id, name, blob_id]` ensures one attachment per name per record
- When you replace an attachment, the old attachment record is deleted and a new one is created

### 3. `active_storage_variant_records`
**Purpose**: Stores information about image variants/transformations (thumbnails, resized versions, etc.).

**Columns**:
- `blob_id` (integer): Foreign key to `active_storage_blobs`
- `variation_digest` (string): Hash representing the transformation parameters
- Unique index on `[blob_id, variation_digest]`

**Key Characteristics**:
- Only used when image variants are requested (e.g., `image.variant(resize_to_limit: [100, 100])`)
- Variants are generated on-demand and cached
- Not used for simple image attachments without transformations

## How Records Are Inserted

### When Uploading an Image to a Post:

1. **File Upload Process**:
   - User selects an image file in the form
   - Form is submitted with `multipart: true` encoding
   - Rails receives the file in `params[:post][:image]`

2. **Blob Creation** (in `active_storage_blobs`):
   - ActiveStorage calculates the file's checksum (MD5)
   - Checks if a blob with this checksum already exists
   - If not, creates a new blob record with:
     - Unique `key` (UUID)
     - Original `filename`
     - `content_type` (detected from file)
     - `byte_size`
     - `checksum`
     - `service_name` (from config, e.g., "local")
     - `metadata` (may include image dimensions if analyzed)
   - The actual file is saved to storage (e.g., `storage/` directory for local)

3. **Attachment Creation** (in `active_storage_attachments`):
   - Creates an attachment record linking the Post to the blob:
     - `name`: "image" (from `has_one_attached :image`)
     - `record_type`: "Post"
     - `record_id`: The post's ID
     - `blob_id`: The blob's ID
   - If the post already had an image, the old attachment is deleted first

4. **Variant Records** (in `active_storage_variant_records`):
   - Only created when image variants are requested
   - For example: `@post.image.variant(resize_to_limit: [500, 500])`
   - Variants are generated lazily and cached

## Example Log Analysis

When uploading an image, you would see SQL queries like:

```sql
-- 1. Check if blob with checksum exists
SELECT "active_storage_blobs".* FROM "active_storage_blobs" 
WHERE "active_storage_blobs"."checksum" = ? LIMIT ?

-- 2. Insert new blob (if checksum doesn't exist)
INSERT INTO "active_storage_blobs" 
("key", "filename", "content_type", "metadata", "service_name", "byte_size", "checksum", "created_at") 
VALUES (?, ?, ?, ?, ?, ?, ?, ?)

-- 3. Delete old attachment (if replacing existing image)
DELETE FROM "active_storage_attachments" 
WHERE "active_storage_attachments"."record_id" = ? 
AND "active_storage_attachments"."record_type" = ? 
AND "active_storage_attachments"."name" = ?

-- 4. Insert new attachment
INSERT INTO "active_storage_attachments" 
("name", "record_type", "record_id", "blob_id", "created_at") 
VALUES (?, ?, ?, ?, ?)
```

## Key Benefits of This Design

1. **Deduplication**: Same file uploaded multiple times shares the same blob
2. **Polymorphism**: Any model can have attachments without schema changes
3. **Flexibility**: Easy to add multiple attachment types per model
4. **Storage Abstraction**: Can switch between local, S3, Google Cloud, etc. without code changes
5. **Efficiency**: Variants are generated on-demand and cached

## Storage Location

For local storage (development/test):
- Files are stored in: `storage/` directory
- Structure: `storage/[first 2 chars of key]/[next 2 chars]/[rest of key]`
- Example: `storage/xy/ab/xyabcdef123456789...`

## Notes

- When a post is destroyed, the attachment is automatically deleted (due to `dependent: :destroy`)
- The blob may remain if other records reference it (shared blob scenario)
- ActiveStorage handles cleanup of orphaned blobs through background jobs

