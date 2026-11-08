package com.aistudio.smartcostpro.app.domain.model

import kotlinx.serialization.Serializable

/**
 * The unified expense record used by the dashboard, reports and recent operations.
 *
 * @param id Stable identifier (UUID for new records; preserved when migrating
 *   from the original SMART COST JSON).
 * @param title Display title (mandatory per spec).
 * @param amount Strictly greater than zero (validated by `ExpenseCalculator`).
 * @param type One of the eight [ExpenseType]s — never null.
 * @param category Free-form category code ("breakfast", "lunch", "gasoline_92", etc.).
 * @param date ISO date (YYYY-MM-DD). Mandatory.
 * @param paymentMethod Optional — defaults to [PaymentMethod.Cash].
 * @param notes Free text up to 2000 characters (per spec).
 * @param detailsJson Optional JSON-encoded extension payload.
 *   - For students: `{ "studentId": "...", "subCategory": "lessons" }`
 *   - For medical: family member, facility, condition, diagnosis, costs...
 *   - For maintenance: supply price + labor price as separate fields.
 *   The spec explicitly forbids dropping this JSON when migrating to Android.
 * @param createdAt Epoch milliseconds when the record was created.
 * @param updatedAt Epoch milliseconds when the record was last updated.
 */
@Serializable
data class Expense(
    val id: String,
    val title: String,
    val amount: Double,
    val type: ExpenseType,
    val category: String,
    val date: String, // YYYY-MM-DD
    val paymentMethod: PaymentMethod = PaymentMethod.Cash,
    val notes: String? = null,
    val detailsJson: String? = null,
    val createdAt: Long,
    val updatedAt: Long
)

