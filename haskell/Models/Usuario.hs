module Models.Usuario where

import Models.Alimentos
import Models.ExercicioRegistrado
import Models.ExerciciosAerobicos
import Models.ExerciciosAnaerobicos

import Data.Time.Clock (UTCTime)


import Data.Time (UTCTime, getCurrentTime, utctDay)
import Data.List
import System.IO

import Data.List.Split

data Usuario = Usuario {
    senha :: String,
    nome_pessoa :: String,
    genero :: String,
    idade :: Int,
    peso :: Float,
    altura :: Float,
    meta_peso :: Float,
    metaKcal :: Float,
    kcalAtual :: Float,
    exerciciosAerobicos :: [ExercicioRegistrado],
    exerciciosAnaerobicos :: [ExercicioRegistrado],
    cafe :: [Alimento],
    almoco :: [Alimento],
    lanche :: [Alimento],
    janta :: [Alimento]
  } deriving (Show)

-- Função para analisar uma linha do arquivo e criar um valor do tipo Usuario
parseUsuario :: String -> Usuario
parseUsuario linha =
  let campos = splitOn " | " linha
      senhaUsuario = campos !! 0
      nomeUsuario = campos !! 1
      generoUsuario = campos !! 2
      idadeUsuario = read (campos !! 3) :: Int
      pesoUsuario = read (campos !! 4) :: Float
      alturaUsuario = read (campos !! 5) :: Float
      metaPesoUsuario = read (campos !! 6) :: Float
      metaKcalUsuario = read (campos !! 7) :: Float
      kcalAtualUsuario = read (campos !! 8) :: Float
      exerciciosAerobicosStr = splitOn "," (campos !! 9)
      exerciciosAnaerobicosStr = splitOn "," (campos !! 10)
      cafeStr = splitOn "," (campos !! 11)
      almocoStr = splitOn "," (campos !! 12)
      lancheStr = splitOn "," (campos !! 13)
      jantaStr = splitOn "," (campos !! 14)
      
      exerciciosAnaerobicos = map (\s -> ExercicioRegistrado (Left (createExercicioAnaerobico s)) 0 undefined 0) exerciciosAnaerobicosStr
      exerciciosAerobicos = map (\s -> ExercicioRegistrado (Right (createExercicioAerobico s)) 0 undefined 0) exerciciosAerobicosStr
      cafe = map (\s -> Alimento s 0 0 0 0) cafeStr
      almoco = map (\s -> Alimento s 0 0 0 0) almocoStr
      lanche = map (\s -> Alimento s 0 0 0 0) lancheStr
      janta = map (\s -> Alimento s 0 0 0 0) jantaStr
  in Usuario
    { senha = senhaUsuario,
      nome_pessoa = nomeUsuario,
      genero = generoUsuario,
      idade = idadeUsuario,
      peso = pesoUsuario,
      altura = alturaUsuario,
      meta_peso = metaPesoUsuario,
      metaKcal = metaKcalUsuario,
      kcalAtual = kcalAtualUsuario,
      exerciciosAerobicos = exerciciosAerobicos,
      exerciciosAnaerobicos = exerciciosAnaerobicos,
      cafe = cafe,
      almoco = almoco,
      lanche = lanche,
      janta = janta
    }
    
-- Função para criar um ExercicioAnaerobico a partir de uma String
createExercicioAnaerobico :: String -> ExercicioAnaerobico
createExercicioAnaerobico str =
  let [nome, area, seriesStr, repeticoesStr, pesoStr] = words str
      seriesInt = read seriesStr :: Int
      repeticoesInt = read repeticoesStr :: Int
      pesoFloat = read pesoStr :: Float
  in ExercicioAnaerobico { nomeExercicioAnaerobico = nome, areaMuscular = area, seriesAnaerobico = seriesInt, repeticoesAnaerobico = repeticoesInt, pesoAnaerobico = pesoFloat }

-- Função para criar um ExercicioAerobico a partir de uma String
createExercicioAerobico :: String -> ExercicioAerobico
createExercicioAerobico str =
  let [nome, metStr] = words str
      metFloat = read metStr :: Float
  in ExercicioAerobico { nomeExercicioAerobico = nome, met = metFloat }

buscarUsuarioPorSenha :: FilePath -> String -> IO (Maybe Usuario)
buscarUsuarioPorSenha arquivo senhaVerificacao = do
  conteudo <- readFile arquivo
  let linhas = lines conteudo
  let usuarioEncontrado = find (\linha -> (head (splitOn " | " linha)) == senhaVerificacao) linhas
  case usuarioEncontrado of
    Just linha -> return (Just (parseUsuario linha))
    Nothing -> return Nothing

-- Função para converter um usuário em uma string no formato desejado
showUsuario :: Usuario -> String
showUsuario usuario =
  senha usuario ++ " | " ++
  nome_pessoa usuario ++ " | " ++
  genero usuario ++ " | " ++
  show (idade usuario) ++ " | " ++
  show (peso usuario) ++ " | " ++
  show (altura usuario) ++ " | " ++
  show (meta_peso usuario) ++ " | " ++
  show (metaKcal usuario) ++ " | " ++
  show (kcalAtual usuario) ++ " | " ++
  showExercicios (exerciciosAerobicos usuario) ++ " | " ++
  showExercicios (exerciciosAnaerobicos usuario) ++ " | " ++
  showAlimentos (cafe usuario) ++ " | " ++
  showAlimentos (almoco usuario) ++ " | " ++
  showAlimentos (lanche usuario) ++ " | " ++
  showAlimentos (janta usuario)

-- Função para converter uma lista de exercícios em uma string no formato desejado
showExercicios :: [ExercicioRegistrado] -> String
showExercicios exercicios =
  unwords (map showExercicio exercicios)

-- Função para converter uma lista de alimentos em uma string no formato desejado
showAlimentos :: [Alimento] -> String
showAlimentos alimentos =
  unwords (map nome_alimento alimentos)

showAlimento :: Alimento -> String
showAlimento alimento =
  nome_alimento alimento ++ " | " ++ show (kcal alimento) ++
  " | " ++ show (proteinas alimento) ++
  " | " ++ show (gorduras alimento) ++
  " | " ++ show (carboidratos alimento)

showExercicio :: ExercicioRegistrado -> String
showExercicio exercicio =
  case exercicio of
    ExercicioRegistrado (Left (ExercicioAnaerobico nome areaMuscular series repeticoes peso)) tempo dataHora kcal ->
      showAnaerobico nome areaMuscular series repeticoes peso tempo dataHora kcal
    ExercicioRegistrado (Right (ExercicioAerobico nome met)) tempo dataHora kcal ->
      showAerobico nome met tempo dataHora kcal
  where
    showAerobico nome met tempo dataHora kcal = nome ++ " | " ++ show met ++ " | " ++ show tempo ++ " | " ++ show dataHora ++ " | " ++ show kcal
    showAnaerobico nome areaMuscular series repeticoes peso tempo dataHora kcal = nome ++ " | " ++ areaMuscular ++ " | " ++ show series ++ " | " ++ show repeticoes ++ " | " ++ show peso ++ " | " ++ show tempo ++ " | " ++ show dataHora ++ " | " ++ show kcal

-- Função para salvar o usuário no arquivo
salvarUsuario :: Usuario -> IO ()
salvarUsuario usuario = do
  putStrLn "Digite sua senha para confirmar a alteração:"
  senhaConfirmacao <- getLine
  if senhaConfirmacao == senha usuario
    then do
      atualizarEAdicionarUsuario "Usuarios.txt" (senha usuario) usuario
    else do
      putStrLn "Senha incorreta. As alterações não serão salvas."

lerUsuarios :: FilePath -> IO [Usuario]
lerUsuarios arquivo = do
  conteudo <- readFile arquivo
  let linhas = lines conteudo
  let usuarios = map (parseUsuario . unwords . words) linhas
  return usuarios

atualizarEAdicionarUsuario :: FilePath -> String -> Usuario -> IO ()
atualizarEAdicionarUsuario arquivo senhaAtualizado novoUsuario = do
  conteudo <- readFile arquivo
  let linhas = lines conteudo
      usuarios = map parseUsuario linhas
  let usuariosAtualizados = atualizarEAdicionarUsuarioNaLista senhaAtualizado novoUsuario usuarios
  let linhasAtualizadas = map showUsuario usuariosAtualizados
  writeFile arquivo (unlines linhasAtualizadas)

atualizarEAdicionarUsuarioNaLista :: String -> Usuario -> [Usuario] -> [Usuario]
atualizarEAdicionarUsuarioNaLista _ _ [] = []
atualizarEAdicionarUsuarioNaLista senhaAtualizado novoUsuario (u:us)
  | senha u == senhaAtualizado = novoUsuario : us
  | otherwise = u : atualizarEAdicionarUsuarioNaLista senhaAtualizado novoUsuario us

-- Função para substituir um usuário no arquivo
substituirUsuario :: FilePath -> Usuario -> IO ()
substituirUsuario arquivo novoUsuario = do
  -- Lê todos os usuários do arquivo
  usuarios <- lerUsuarios arquivo
  -- Remove o usuário antigo (se existir)
  let usuariosAtualizados = filter (\u -> senha u /= senha novoUsuario) usuarios
  -- Adiciona o novo usuário à lista
  let usuariosNovos = novoUsuario : usuariosAtualizados
  -- Escreve a lista de usuários atualizada no arquivo
  writeFile arquivo (unlines (map show usuariosNovos))

-- Função para atualizar o peso do usuário
atualizarPeso :: Usuario -> IO Usuario
atualizarPeso usuario = do
  putStrLn "Digite o novo peso: "
  peso <- getLine
  let pesoValido = peso /= "" && read peso > 0
  if pesoValido
    then do
      let novoPeso = read peso
      let usuarioAtualizado = usuario { peso = novoPeso }
      putStrLn "Peso atualizado com sucesso!"
      return usuarioAtualizado
    else do
      putStrLn "Peso inválido. Digite um valor positivo."
      return usuario

-- Função para atualizar a meta do usuário
atualizarMeta :: Usuario -> IO Usuario
atualizarMeta usuario = do
  putStrLn "Digite o novo valor da meta: "
  novaMetaStr <- getLine
  if read novaMetaStr > 0.0
    then do
      let novaMeta = read novaMetaStr :: Float
          usuarioAtualizado = usuario { meta_peso = novaMeta }
      putStrLn "Meta atualizada com sucesso!"
      return usuarioAtualizado
    else do
      putStrLn "Meta inválida. Insira um valor numérico maior que 0.0."
      return usuario

-- Função para atualizar a idade do usuário
atualizarIdade :: Usuario -> IO Usuario
atualizarIdade usuario = do
  putStrLn "Digite a nova idade: "
  idade <- getLine
  let idadeValida = idade /= "" && read idade > 0 && read idade < 100
  if idadeValida
    then do
      let novaIdade = read idade
      let usuarioAtualizado = usuario { idade = novaIdade }
      putStrLn "Idade atualizada com sucesso!"
      return usuarioAtualizado
    else do
      putStrLn "Idade inválida. Digite um valor entre 1 e 99."
      return usuario

-- Função para atualizar a senha do usuário (OLHAR MELHOR ESSA PARTE E COMO É FEITA A ENTRADA PELA SENHA)
atualizarSenha :: Usuario -> IO Usuario
atualizarSenha usuario = do
  putStrLn "Digite a nova senha: "
  novaSenha <- getLine
  let usuarioAtualizado = usuario { senha = novaSenha }
  putStrLn "Senha atualizada com sucesso!"
  return usuarioAtualizado



findUsuario :: String -> [Usuario] -> Maybe Usuario
findUsuario _ [] = Nothing
findUsuario senh (u:us) = if senh == senha u
                            then Just u 
                            else findUsuario senh us

-- Função para calcular as calorias diárias necessárias para manter o peso
caloriasManterPeso :: Usuario -> Float
caloriasManterPeso usuario
  | genero usuario == "M" = 88.362 + (13.397 * peso usuario) + (4.799 * altura usuario) - (5.677 * fromIntegral (idade usuario))
  | genero usuario == "F" = 447.593 + (9.247 * peso usuario) + (3.098 * altura usuario) - (4.330 * fromIntegral (idade usuario))
  | otherwise = 0.0

-- Função para calcular o valor total das calorias diárias para perder peso
caloriasDiariasPerderPeso :: Usuario -> Float -> Float
caloriasDiariasPerderPeso usuario metaPeso = caloriasManterPeso usuario - (500 * (peso usuario - metaPeso))

-- Função para calcular o valor total das calorias diárias para ganhar peso
caloriasDiariasGanharPeso :: Usuario -> Float -> Float
caloriasDiariasGanharPeso usuario metaPeso = caloriasManterPeso usuario + (500 * (metaPeso - peso usuario))

-- Função para obter exercícios aeróbicos do dia
exerciciosAerobicosDoDia :: Usuario -> IO [ExercicioRegistrado]
exerciciosAerobicosDoDia usuario = do
  exerciciosRegistrados <- return $ exerciciosAerobicos usuario
  dataAtual <- getCurrentTime
  return $ filter (\exercicio -> sameDay (dataHoraExercicio exercicio) dataAtual) exerciciosRegistrados

-- Função para obter todos os exercícios anaeróbicos feitos
exerciciosAerobicosTodos :: Usuario -> [ExercicioRegistrado]
exerciciosAerobicosTodos usuario = exerciciosAerobicos usuario


adicionarExercicioAerobico :: Usuario -> IO Usuario
adicionarExercicioAerobico usuario = do
  putStrLn "Digite o nome do exercício aeróbico:"
  nomeExercicio <- getLine
  putStrLn "Digite a duração do exercício (em horas):"
  duracaoStr <- getLine
  
  let duracao = read duracaoStr :: Float
  
  exercicioAerobicoEncontrado <- buscarExercicioAerobicoPorNome "exerciciosAerobicos.txt" nomeExercicio

  case exercicioAerobicoEncontrado of
    Just exercicioAerobico -> do
      let metExercicio = met exercicioAerobico
      let pesoUsuario = peso usuario

      -- Calcula o gasto calórico com base no MET, peso do usuário e duração do exercício
      let gastoCalorico = calcularPerdaCaloricaAerobico metExercicio pesoUsuario duracao

      -- Obtém a hora atual
      horaAtual <- getCurrentTime

      -- Cria o exercício registrado
      let exercicioRegistrado = ExercicioRegistrado
            { exercicioRealizado = Right exercicioAerobico
            , tempoGastoExercicio = duracao
            , dataHoraExercicio = horaAtual
            , kcalGasto = gastoCalorico
            }

      let novoUsuario = usuario { exerciciosAerobicos = exercicioRegistrado : exerciciosAerobicos usuario }

      putStrLn $ "Exercício aeróbico adicionado com sucesso! Gasto calórico: " ++ show gastoCalorico ++ " calorias."

      return novoUsuario

    Nothing -> do
      putStrLn "Exercício aeróbico não encontrado."
      return usuario


exerciciosAnaerobicosDoDia :: Usuario -> IO [ExercicioRegistrado]
exerciciosAnaerobicosDoDia usuario = do
  exerciciosRegistrados <- return $ exerciciosAnaerobicos usuario
  dataAtual <- getCurrentTime
  return $ filter (\exercicio -> sameDay (dataHoraExercicio exercicio) dataAtual) exerciciosRegistrados

-- Função para obter todos os exercícios anaeróbicos feitos
exerciciosAnaerobicosTodos :: Usuario -> [ExercicioRegistrado]
exerciciosAnaerobicosTodos usuario = exerciciosAnaerobicos usuario

adicionarExercicioAnaerobico :: Usuario -> IO Usuario
adicionarExercicioAnaerobico usuario = do
  putStrLn "Digite o nome do exercício anaeróbico:"
  nomeExercicio <- getLine
  putStrLn "Digite a duração do exercício (em horas):"
  duracaoStr <- getLine
  putStrLn "Digite quantas séries foram feitas:"
  seriesStr <- getLine
  putStrLn "Digite quantas repetições por série:"
  repeticoesStr <- getLine
  
  let duracao = read duracaoStr :: Float
  let series = read seriesStr :: Int
  let repeticoes = read repeticoesStr :: Int
  
  exercicioAnaerobicoEncontrado <- buscarExercicioAnaerobicoPorNome "exerciciosAnaerobicos.txt" nomeExercicio

  case exercicioAnaerobicoEncontrado of
    Just exercicioAnaerobico -> do
      let pesoUsuario = peso usuario

      let gastoCalorico = calcularPerdaCaloricaAnaerobico pesoUsuario duracao

      horaAtual <- getCurrentTime

      let exercicioRegistrado = ExercicioRegistrado
            { exercicioRealizado = Left exercicioAnaerobico
            , tempoGastoExercicio = duracao
            , dataHoraExercicio = horaAtual
            , kcalGasto = gastoCalorico
            }

      let novoUsuario = usuario { exerciciosAnaerobicos = exercicioRegistrado : exerciciosAnaerobicos usuario }

      putStrLn $ "Exercício anaeróbico adicionado com sucesso! Gasto calórico: " ++ show gastoCalorico ++ " calorias."

      return novoUsuario

    Nothing -> do
      putStrLn "Exercício anaeróbico não encontrado."
      return usuario