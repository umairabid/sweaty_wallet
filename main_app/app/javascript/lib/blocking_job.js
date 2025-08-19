import { post, get } from '@rails/request.js'
import consumer from "channels/consumer"


export function blockingJob(options) {
  const url = options.url
  blockUi()
  return new Promise((resolve, reject) => {
    const jobPromise = post(url, { body: JSON.stringify(options.params || {})})
    jobPromise.then(response => {
      if (response.ok) {
        response.json.then(json => {
          const job_id = json.job_id
          waitForJob(job_id, resolve, reject)
        })
      } else {
        reject({ status: 'error' })
      }
    })
  })
}

function waitForJob(job_id, resolve, reject) {
  const channel = consumer.subscriptions.create(
    {
      channel: "BackgroundProcessChannel",
      job_id: job_id,
    },
    {
      received: (data) => {
        if (data.status == "finished") {
          unblockUi()
          resolve(data)
        } else if (data.status == "error") {
          unblockUi()
          reject(data)
        }
      },
    }
  )
}

function blockUi() {
  const overlay = document.createElement('div')
    overlay.id = 'global-loading-overlay'
    overlay.innerHTML = `
      <div class="loading-spinner">Loading...</div>
    `
    Object.assign(overlay.style, {
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      background: 'rgba(255, 255, 255, 0.8)',
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      zIndex: 9999,
    })

    const spinner = overlay.querySelector('.loading-spinner')
    Object.assign(spinner.style, {
      padding: '1em 2em',
      background: '#000',
      color: '#fff',
      borderRadius: '8px',
      fontSize: '1.2em',
    })

    document.body.appendChild(overlay)
}

function unblockUi() {
  const overlay = document.getElementById('global-loading-overlay')
  if (overlay) {
    document.body.removeChild(overlay)
  }
}

