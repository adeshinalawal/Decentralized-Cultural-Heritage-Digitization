;; Artifact Registration Contract
;; Records details of cultural items being digitized

(define-data-var last-id uint u0)

(define-map artifacts
  { id: uint }
  {
    name: (string-ascii 100),
    culture: (string-ascii 50),
    description: (string-ascii 200),
    physical-location: (string-ascii 100),
    creation-date: (string-ascii 50),
    registrar: principal,
    digital-hash: (string-ascii 64)
  }
)

;; Register artifact
(define-public (register
    (name (string-ascii 100))
    (culture (string-ascii 50))
    (description (string-ascii 200))
    (physical-location (string-ascii 100))
    (creation-date (string-ascii 50))
    (digital-hash (string-ascii 64))
  )
  (let
    (
      (new-id (+ (var-get last-id) u1))
    )
    (var-set last-id new-id)

    (map-set artifacts
      { id: new-id }
      {
        name: name,
        culture: culture,
        description: description,
        physical-location: physical-location,
        creation-date: creation-date,
        registrar: tx-sender,
        digital-hash: digital-hash
      }
    )

    (ok new-id)
  )
)

;; Update digital hash
(define-public (update-digital-hash
    (artifact-id uint)
    (digital-hash (string-ascii 64))
  )
  (let
    (
      (artifact (unwrap! (map-get? artifacts { id: artifact-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get registrar artifact)) (err u403))

    (map-set artifacts
      { id: artifact-id }
      (merge artifact { digital-hash: digital-hash })
    )

    (ok true)
  )
)

;; Get artifact
(define-read-only (get-artifact (id uint))
  (map-get? artifacts { id: id })
)
