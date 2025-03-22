;; Digital Preservation Contract
;; Tracks storage and backup of digital records

(define-data-var last-id uint u0)

(define-map preservation-records
  { id: uint }
  {
    artifact-id: uint,
    storage-location: (string-ascii 100),
    backup-location: (string-ascii 100),
    format: (string-ascii 50),
    resolution: (string-ascii 50),
    last-verified: uint,
    custodian: principal
  }
)

;; Record preservation
(define-public (record-preservation
    (artifact-id uint)
    (storage-location (string-ascii 100))
    (backup-location (string-ascii 100))
    (format (string-ascii 50))
    (resolution (string-ascii 50))
  )
  (let
    (
      (new-id (+ (var-get last-id) u1))
    )
    (var-set last-id new-id)

    (map-set preservation-records
      { id: new-id }
      {
        artifact-id: artifact-id,
        storage-location: storage-location,
        backup-location: backup-location,
        format: format,
        resolution: resolution,
        last-verified: block-height,
        custodian: tx-sender
      }
    )

    (ok new-id)
  )
)

;; Verify preservation
(define-public (verify-preservation
    (record-id uint)
  )
  (let
    (
      (record (unwrap! (map-get? preservation-records { id: record-id }) (err u404)))
    )

    (map-set preservation-records
      { id: record-id }
      (merge record { last-verified: block-height })
    )

    (ok true)
  )
)

;; Update storage location
(define-public (update-storage
    (record-id uint)
    (storage-location (string-ascii 100))
    (backup-location (string-ascii 100))
  )
  (let
    (
      (record (unwrap! (map-get? preservation-records { id: record-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get custodian record)) (err u403))

    (map-set preservation-records
      { id: record-id }
      (merge record {
        storage-location: storage-location,
        backup-location: backup-location,
        last-verified: block-height
      })
    )

    (ok true)
  )
)

;; Get preservation record
(define-read-only (get-preservation-record (id uint))
  (map-get? preservation-records { id: id })
)
