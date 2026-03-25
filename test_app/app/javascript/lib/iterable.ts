export function partition<T>(list : Iterable<T>, filterFn : ((item: T)=>boolean) | RegExp) {
  const yes = [], no = [];
  if(filterFn instanceof RegExp) {
    for(const item of (list as Iterable<string>)){
      if(filterFn.test(item)) yes.push(item);
      else no.push(item);
    }
  } else {
    for(const item of list){
      if(filterFn(item)) yes.push(item);
      else no.push(item);
    }
  }
  return [yes, no]
}