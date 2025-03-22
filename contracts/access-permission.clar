;; Access Permission Contract
;; Manages viewing rights based on cultural protocols

(define-data-var last-id uint u0)

(define-map permissions
  { id: uint }
  {
    artifact-id: uint,
    access-level: (string-ascii 20),
    cultural-protocol: (string-ascii 200),
    community-approved: bool,
    approver: principal,
    public-access: bool
  }
)

(define-map user-permissions
  { permission-id: uint, user: principal }
  {
    granted: bool,
    granted-by: principal,
    granted-at: uint
  }
)

;; Set permission
(define-public (set-permission
    (artifact-id uint)
    (access-level (string-ascii 20))
    (cultural-protocol (string-ascii 200))
    (public-access bool)
  )
  (let
    (
      (new-id (+ (var-get last-id) u1))
    )
    (var-set last-id new-id)

    (map-set permissions
      { id: new-id }
      {
        artifact-id: artifact-id,
        access-level: access-level,
        cultural-protocol: cultural-protocol,
        community-approved: false,
        approver: tx-sender,
        public-access: public-access
      }
    )

    (ok new-id)
  )
)

;; Approve permission
(define-public (approve-permission
    (permission-id uint)
  )
  (let
    (
      (permission (unwrap! (map-get? permissions { id: permission-id }) (err u404)))
    )

    (map-set permissions
      { id: permission-id }
      (merge permission {
        community-approved: true,
        approver: tx-sender
      })
    )

    (ok true)
  )
)

;; Grant user permission
(define-public (grant-user-permission
    (permission-id uint)
    (user principal)
  )
  (let
    (
      (permission (unwrap! (map-get? permissions { id: permission-id }) (err u404)))
    )

    (map-set user-permissions
      { permission-id: permission-id, user: user }
      {
        granted: true,
        granted-by: tx-sender,
        granted-at: block-height
      }
    )

    (ok true)
  )
)

;; Check user permission
(define-read-only (check-user-permission (permission-id uint) (user principal))
  (let
    (
      (permission (map-get? permissions { id: permission-id }))
      (user-permission (map-get? user-permissions { permission-id: permission-id, user: user }))
    )
    (if (and (is-some permission) (get public-access (unwrap! permission false)))
      true
      (if (and (is-some user-permission) (get granted (unwrap! user-permission false)))
        true
        false
      )
    )
  )
)

;; Get permission
(define-read-only (get-permission (id uint))
  (map-get? permissions { id: id })
)
