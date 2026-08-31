/**
 * Post-generate hardening.
 *
 * Nuxt Content prerenders `__nuxt_content/<collection>/sql_dump.txt` so the
 * browser can run queries client-side. That dump contains every row of the
 * `dossiers` collection — i.e. a public, complete list of every client slug and
 * its full text. The whole v1 security model is "the slug is unguessable", so
 * shipping an index of the slugs would defeat it entirely.
 *
 * Every page here is prerendered with its own payload and nothing links between
 * client pages, so no client-side content query ever runs. The dump is dead
 * weight: delete it before deploy.
 */
import { existsSync, rmSync } from 'node:fs'
import { fileURLToPath } from 'node:url'

const dumpDir = fileURLToPath(new URL('../.output/public/__nuxt_content', import.meta.url))

if (existsSync(dumpDir)) {
  rmSync(dumpDir, { recursive: true, force: true })
  console.log('[harden] removed .output/public/__nuxt_content (client-slug index)')
} else {
  console.log('[harden] no __nuxt_content directory in output — nothing to remove')
}
