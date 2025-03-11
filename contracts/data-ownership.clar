;; data-ownership.clar
;; This contract establishes individual control over personal data

(define-map personal-data
  { owner: principal }
  {
    data-hash: (buff 32),
    description: (string-ascii 256),
    created-at: uint,
    updated-at: uint
  }
)

(define-read-only (get-personal-data (owner principal))
  (map-get? personal-data { owner: owner })
)

(define-public (register-data (data-hash (buff 32)) (description (string-ascii 256)))
  (let
    (
      (existing-data (get-personal-data tx-sender))
    )
    (asserts! (is-none existing-data) (err u1)) ;; Error if data already registered
    (ok (map-set personal-data
      { owner: tx-sender }
      {
        data-hash: data-hash,
        description: description,
        created-at: block-height,
        updated-at: block-height
      }
    ))
  )
)

(define-public (update-data (data-hash (buff 32)) (description (string-ascii 256)))
  (let
    (
      (existing-data (unwrap! (get-personal-data tx-sender) (err u2))) ;; Error if no data found
    )
    (ok (map-set personal-data
      { owner: tx-sender }
      (merge existing-data
        {
          data-hash: data-hash,
          description: description,
          updated-at: block-height
        }
      )
    ))
  )
)

(define-public (delete-data)
  (begin
    (asserts! (is-some (get-personal-data tx-sender)) (err u3)) ;; Error if no data found
    (ok (map-delete personal-data { owner: tx-sender }))
  )
)

