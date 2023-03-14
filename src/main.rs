// main.rs

use rlua::{
  Lua, Result
};


fn main() -> Result<()> {
  let lua = Lua::new();

  lua.context(|lua_ctx| {
    lua_ctx.load(r#"print("Hello, world!")"#).exec()?;

    Ok(())
  })?;

  Ok(())
}
