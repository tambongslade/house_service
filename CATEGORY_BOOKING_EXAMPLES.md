# Category-Based Booking - Quick Test Examples

## 🚀 Complete Test Payloads

### 1. Basic Booking (No Coupon)

```bash
POST /api/v1/bookings/initiate
```

```json
{
  "category": "cleaning",
  "sessionDate": "2025-11-15",
  "startTime": "09:00",
  "duration": 4,
  "paymentDetails": {
    "phone": "237670527426",
    "medium": "mobile money"
  }
}
```

---

### 2. Booking with Coupon

```json
{
  "category": "plumbing",
  "sessionDate": "2025-11-20",
  "startTime": "14:00",
  "duration": 3,
  "paymentDetails": {
    "phone": "237670527426",
    "medium": "mobile money",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "couponCode": "SAVE30",
  "notes": "Emergency pipe repair needed"
}
```

---

### 3. All Categories Examples

```json
// Cleaning
{
  "category": "cleaning",
  "sessionDate": "2025-11-15",
  "startTime": "08:00",
  "duration": 5,
  "paymentDetails": { "phone": "237670527426", "medium": "mobile money" }
}

// Plumbing
{
  "category": "plumbing",
  "sessionDate": "2025-11-16",
  "startTime": "10:00",
  "duration": 2.5,
  "paymentDetails": { "phone": "237670527426", "medium": "orange money" }
}

// Electrical
{
  "category": "electrical",
  "sessionDate": "2025-11-17",
  "startTime": "13:00",
  "duration": 3,
  "paymentDetails": { "phone": "237670527426", "medium": "mobile money" }
}

// Painting
{
  "category": "painting",
  "sessionDate": "2025-11-18",
  "startTime": "07:00",
  "duration": 8,
  "paymentDetails": { "phone": "237670527426", "medium": "mobile money" }
}

// Gardening
{
  "category": "gardening",
  "sessionDate": "2025-11-19",
  "startTime": "06:00",
  "duration": 4,
  "paymentDetails": { "phone": "237670527426", "medium": "mobile money" }
}

// Carpentry
{
  "category": "carpentry",
  "sessionDate": "2025-11-20",
  "startTime": "09:00",
  "duration": 6,
  "paymentDetails": { "phone": "237670527426", "medium": "orange money" }
}

// Cooking
{
  "category": "cooking",
  "sessionDate": "2025-11-21",
  "startTime": "17:00",
  "duration": 3,
  "paymentDetails": { "phone": "237670527426", "medium": "mobile money" },
  "notes": "Birthday dinner for 10 people"
}

// Tutoring
{
  "category": "tutoring",
  "sessionDate": "2025-11-22",
  "startTime": "15:00",
  "duration": 2,
  "paymentDetails": { "phone": "237670527426", "medium": "mobile money" },
  "notes": "Math tutoring - calculus"
}

// Beauty
{
  "category": "beauty",
  "sessionDate": "2025-11-23",
  "startTime": "11:00",
  "duration": 2.5,
  "paymentDetails": { "phone": "237670527426", "medium": "mobile money" }
}

// Maintenance
{
  "category": "maintenance",
  "sessionDate": "2025-11-24",
  "startTime": "08:30",
  "duration": 4,
  "paymentDetails": { "phone": "237670527426", "medium": "mobile money" },
  "notes": "General home maintenance checkup"
}

// Other
{
  "category": "other",
  "sessionDate": "2025-11-25",
  "startTime": "10:00",
  "duration": 3,
  "paymentDetails": { "phone": "237670527426", "medium": "mobile money" },
  "notes": "Custom service request"
}
```

---

### 4. Admin Assignment Examples

#### Assign Provider

```bash
POST /api/v1/admin/assignments/assign
```

```json
{
  "sessionId": "673f8b2e4f5e6a9876543210",
  "providerId": "673f8b2e4f5e6a1111111111",
  "notes": "Assigned top-rated provider"
}
```

#### Assign Provider with Specific Service

```json
{
  "sessionId": "673f8b2e4f5e6a9876543210",
  "providerId": "673f8b2e4f5e6a1111111111",
  "serviceId": "673f8b2e4f5e6a3333333333",
  "notes": "Assigned provider's premium cleaning service"
}
```

#### Reject Service Request

```bash
POST /api/v1/admin/assignments/:sessionId/reject
```

```json
{
  "reason": "No providers available in requested area",
  "adminNotes": "Customer notified via email. Refund processed."
}
```

---

## 🧪 cURL Examples

### Create Booking

```bash
curl -X POST https://api.homeaideservice.com/api/v1/bookings/initiate \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "category": "cleaning",
    "sessionDate": "2025-11-15",
    "startTime": "09:00",
    "duration": 4,
    "paymentDetails": {
      "phone": "237670527426",
      "medium": "mobile money"
    },
    "couponCode": "SAVE20"
  }'
```

### Check Status

```bash
curl -X GET https://api.homeaideservice.com/api/v1/bookings/status/temp_booking_1730198400000_673f8b2e \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get Pending Assignments (Admin)

```bash
curl -X GET https://api.homeaideservice.com/api/v1/admin/assignments/pending \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

### Find Available Providers (Admin)

```bash
curl -X GET "https://api.homeaideservice.com/api/v1/admin/assignments/sessions/673f8b2e4f5e6a9876543210/providers?minRating=4.5" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

### Assign Provider (Admin)

```bash
curl -X POST https://api.homeaideservice.com/api/v1/admin/assignments/assign \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "673f8b2e4f5e6a9876543210",
    "providerId": "673f8b2e4f5e6a1111111111",
    "notes": "Best match for this area"
  }'
```

---

## ⚠️ Common Validation Errors

### Invalid Category

```json
{
  "statusCode": 400,
  "message": "category must be one of the following values: cleaning, plumbing, electrical, painting, gardening, carpentry, cooking, tutoring, beauty, maintenance, other",
  "error": "Bad Request"
}
```

**Fix:** Use a valid category from the list.

---

### Invalid Phone Number

```json
{
  "statusCode": 400,
  "message": "Phone number must be in format 237XXXXXXXXX",
  "error": "Bad Request"
}
```

**Fix:** Use format `237670527426` (237 + 9 digits)

---

### Invalid Duration

```json
{
  "statusCode": 400,
  "message": "Minimum session duration is 0.5 hours",
  "error": "Bad Request"
}
```

**Fix:** Duration must be between 0.5 and 12 hours.

---

### Invalid Coupon

```json
{
  "statusCode": 400,
  "message": "Coupon code has already been used",
  "error": "Bad Request"
}
```

**Fix:** Check coupon validity and usage limits.

---

### Amount Too Low

```json
{
  "statusCode": 400,
  "message": "Final amount must be at least 100 XAF",
  "error": "Bad Request"
}
```

**Fix:** Increase duration or remove coupon.

---

## 📊 Expected Pricing Examples

Based on 3000 FCFA/hour base price:

| Duration | Base Hours | Overtime | Calculation | Total |
|----------|------------|----------|-------------|-------|
| 1 hour | 1 | 0 | 1 × 3000 | 3,000 |
| 2 hours | 2 | 0 | 2 × 3000 | 6,000 |
| 3 hours | 3 | 0 | 3 × 3000 | 9,000 |
| 4 hours | 3 | 1 | (3 × 3000) + (1 × 4500) | 13,500 |
| 5 hours | 3 | 2 | (3 × 3000) + (2 × 4500) | 18,000 |
| 8 hours | 3 | 5 | (3 × 3000) + (5 × 4500) | 31,500 |

**Overtime Rate:** 1.5x base rate = 4,500 FCFA/hour

---

## 🎯 Quick Test Checklist

- [ ] Create booking with valid category
- [ ] Verify payment initiated
- [ ] Complete payment on phone
- [ ] Check status shows "Pending Assignment"
- [ ] Admin views pending assignments
- [ ] Admin finds available providers
- [ ] Admin assigns provider
- [ ] Check status shows provider details
- [ ] Test with coupon code
- [ ] Test admin rejection flow

---

**Happy Testing! 🚀**
