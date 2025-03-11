;; data-access.clar
;; This contract manages permissions for data use by third parties

(define-map data-permissions
  { owner: principal, accessor: principal }
  {
    granted-at: uint,
    expires-at: uint,
    revoked-at: (optional uint)
  }
)

(define-read-only (get-permission (owner principal) (accessor principal))
  (map-get? data-permissions { owner: owner, accessor: accessor })
)

(define-public (grant-access (accessor principal) (duration uint))
  (let
    (
      (expiration (+ block-height duration))
    )
    (ok (map-set data-permissions
      { owner: tx-sender, accessor: accessor }
      {
        granted-at: block-height,
        expires-at: expiration,
        revoked-at: none
      }
    ))
  )
)

(define-public (revoke-access (accessor principal))
  (let
    (
      (permission (unwrap! (get-permission tx-sender accessor) (err u1))) ;; Error if no permission found
    )
    (ok (map-set data-permissions
      { owner: tx-sender, accessor: accessor }
      (merge permission { revoked-at: (some block-height) })
    ))
  )
)

(define-read-only (check-access (owner principal) (accessor principal))
  (match (get-permission owner accessor)
    permission (and
      (>= block-height (get granted-at permission))
      (< block-height (get expires-at permission))
      (is-none (get revoked-at permission))
    )
    false
  )
)

