;; Attribution Contract
;; Ensures proper credit to source communities

(define-data-var last-id uint u0)

(define-map attributions
  { id: uint }
  {
    artifact-id: uint,
    community: (string-ascii 100),
    contributors: (string-ascii 200),
    rights-statement: (string-ascii 200),
    usage-guidelines: (string-ascii 200),
    contact: (string-ascii 100),
    verified: bool
  }
)

;; Record attribution
(define-public (record-attribution
    (artifact-id uint)
    (community (string-ascii 100))
    (contributors (string-ascii 200))
    (rights-statement (string-ascii 200))
    (usage-guidelines (string-ascii 200))
    (contact (string-ascii 100))
  )
  (let
    (
      (new-id (+ (var-get last-id) u1))
    )
    (var-set last-id new-id)

    (map-set attributions
      { id: new-id }
      {
        artifact-id: artifact-id,
        community: community,
        contributors: contributors,
        rights-statement: rights-statement,
        usage-guidelines: usage-guidelines,
        contact: contact,
        verified: false
      }
    )

    (ok new-id)
  )
)

;; Verify attribution
(define-public (verify-attribution
    (attribution-id uint)
  )
  (let
    (
      (attribution (unwrap! (map-get? attributions { id: attribution-id }) (err u404)))
    )

    (map-set attributions
      { id: attribution-id }
      (merge attribution { verified: true })
    )

    (ok true)
  )
)

;; Update attribution
(define-public (update-attribution
    (attribution-id uint)
    (contributors (string-ascii 200))
    (rights-statement (string-ascii 200))
    (usage-guidelines (string-ascii 200))
    (contact (string-ascii 100))
  )
  (let
    (
      (attribution (unwrap! (map-get? attributions { id: attribution-id }) (err u404)))
    )

    (map-set attributions
      { id: attribution-id }
      (merge attribution {
        contributors: contributors,
        rights-statement: rights-statement,
        usage-guidelines: usage-guidelines,
        contact: contact,
        verified: false
      })
    )

    (ok true)
  )
)

;; Get attribution
(define-read-only (get-attribution (id uint))
  (map-get? attributions { id: id })
)
