;; compensation.clar
;; This contract handles payments for data access and usage

(define-map payment-rates
  { owner: principal }
  { rate: uint }
)

(define-map payments
  { payment-id: uint }
  {
    from: principal,
    to: principal,
    amount: uint,
    data-id: (buff 32),
    paid-at: uint
  }
)

(define-data-var last-payment-id uint u0)

(define-read-only (get-payment-rate (owner principal))
  (default-to { rate: u0 } (map-get? payment-rates { owner: owner }))
)

(define-public (set-payment-rate (rate uint))
  (ok (map-set payment-rates { owner: tx-sender } { rate: rate }))
)

(define-public (make-payment (to principal) (data-id (buff 32)))
  (let
    (
      (rate (get rate (get-payment-rate to)))
      (payment-id (+ (var-get last-payment-id) u1))
    )
    (asserts! (> rate u0) (err u1)) ;; Error if rate not set
    (try! (stx-transfer? rate tx-sender to))
    (var-set last-payment-id payment-id)
    (ok (map-set payments
      { payment-id: payment-id }
      {
        from: tx-sender,
        to: to,
        amount: rate,
        data-id: data-id,
        paid-at: block-height
      }
    ))
  )
)

(define-read-only (get-payment (payment-id uint))
  (map-get? payments { payment-id: payment-id })
)

