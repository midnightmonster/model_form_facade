import { registerSvelte, globToComponents } from "../lib/registerSvelte.svelte"

const svelteImports = globToComponents(
  import.meta.glob("../components/*.svelte", { eager: false })
)
registerSvelte(svelteImports)

import * as Turbo from "@hotwired/turbo"
Turbo.start()
