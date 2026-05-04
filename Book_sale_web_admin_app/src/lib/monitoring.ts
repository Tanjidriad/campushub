type MonitoringEvent = {
  level: 'error' | 'warning'
  message: string
  context?: Record<string, unknown>
}

const endpoint = import.meta.env.VITE_MONITORING_ENDPOINT

const sendEvent = (event: MonitoringEvent) => {
  if (!endpoint || typeof navigator === 'undefined' || !navigator.sendBeacon) {
    return
  }

  const payload = JSON.stringify({
    ...event,
    timestamp: new Date().toISOString(),
    app: 'book-sale-web-admin',
    env: import.meta.env.MODE,
  })

  const blob = new Blob([payload], { type: 'application/json' })
  navigator.sendBeacon(endpoint, blob)
}

export const initMonitoring = () => {
  window.addEventListener('error', (event) => {
    sendEvent({
      level: 'error',
      message: event.message || 'Unhandled browser error',
      context: {
        filename: event.filename,
        line: event.lineno,
        column: event.colno,
      },
    })
  })

  window.addEventListener('unhandledrejection', (event) => {
    sendEvent({
      level: 'error',
      message: 'Unhandled promise rejection',
      context: {
        reason: String(event.reason),
      },
    })
  })
}
