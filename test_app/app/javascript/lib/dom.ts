
export function domId(prefix = "id") {
  return `${prefix}-${Math.random().toString(36).substring(2, 15)}`;
}
