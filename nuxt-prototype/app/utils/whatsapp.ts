export const DEFAULT_WHATSAPP_TEXT
  = 'Hi, I read the proposal — let\'s talk about Step 1'

/**
 * Build a wa.me deep link. wa.me wants digits only, no "+" and no spaces.
 */
export function whatsappLink(number: string, text?: string): string {
  const digits = (number || '').replace(/\D/g, '')
  const message = encodeURIComponent(text || DEFAULT_WHATSAPP_TEXT)

  return `https://wa.me/${digits}?text=${message}`
}
