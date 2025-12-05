use crate::error::Error;

pub fn parse_ingredients(string: &str) -> Result<Vec<usize>, Error> {
    let mut ids = vec![];

    for line in string
        .lines()
        .filter(|line| !line.is_empty())
        .map(str::trim)
    {
        let id = line
            .parse::<usize>()
            .or(Err(Error::InvalidIngredientId(line.to_string())))?;

        ids.push(id);
    }

    Ok(ids)
}
