import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

actor {
  // Primero, declaramos la estructura que representará una publicación (Post).
  // Un Post tiene dos campos: un mensaje de texto y una imagen (ambos de tipo Text).
  type Post = {
    message: Text;  // El mensaje de la publicación (texto).
    image: Text;    // La URL o identificador de la imagen asociada a la publicación (texto).
  };

  var postId : Nat = 0; // Inicializamos el contador de identificadores de publicaciones (de tipo Nat, que es un número natural).
  
  // Creamos un HashMap para almacenar las publicaciones.
  // La clave es de tipo Text (el ID del post) y el valor es un Post (la estructura definida anteriormente).
  let posts = HashMap.HashMap<Text, Post>(0, Text.equal, Text.hash);

  // Función privada para generar un nuevo ID único para cada publicación.
  private func generatePostId() : Text {
    postId += 1;  // Incrementamos el contador de publicaciones (ID).
    // Convertimos el número de identificación (postId) a texto para usarlo como clave en el HashMap.
    return Nat.toText(postId);
  };

  // Función pública para crear una nueva publicación (post).
  public func createPost(message: Text, image: Text) {
    let post: Post = { message; image };  // Creamos un nuevo objeto 'post' con el mensaje y la imagen proporcionados.
    let key = generatePostId();          // Generamos un nuevo ID único para el post.
    posts.put(key, post);                // Almacenamos el post en el HashMap usando la clave generada.
    Debug.print("Post successfully created" # key);  // Imprimimos un mensaje de éxito con el ID del post creado.
  };

  // Función query pública para consultar una publicación específica sin modificar nada.
  public query func getPost(key: Text) : async ?Post {
    return posts.get(key); // Devolvemos el post que corresponde a la clave proporcionada.
  };

  // Función query pública para obtener todas las publicaciones.
  public query func getPosts(): async [(Text, Post)] {
    let postIter: Iter.Iter<(Text,Post)> = posts.entries();  // Obtenemos un iterador de todas las entradas del HashMap.
    return Iter.toArray(postIter);  // Convertimos el iterador en un array de tuplas (ID, Post).
  };

  // Función pública para actualizar el contenido de una publicación.
  // Recibe el ID de la publicación y el nuevo mensaje.
  public func updatePost(key: Text, message: Text) : async Bool {
    let post: ?Post = posts.get(key);  // Buscamos la publicación usando la clave proporcionada.

    switch (post) {
      case (null) {  // Si no encontramos el post con esa clave.
        Debug.print("Cannot find post.");  // Imprimimos un mensaje de error.
        return false;  // Retornamos falso porque no se pudo encontrar el post.
      };
      case (?currentPost) {  // Si encontramos el post, lo actualizamos.
        let newPost: Post = { message; image = currentPost.image };  // Creamos un nuevo post con el mensaje actualizado y la imagen sin cambios.
        posts.put(key, newPost);  // Reemplazamos el post anterior en el HashMap.
        Debug.print("Post updated");  // Imprimimos un mensaje de éxito.
        return true;  // Retornamos verdadero porque el post fue actualizado exitosamente.
      };
    };
  };

  // Función pública para eliminar una publicación.
  public func deletePost(key: Text): async Bool {
    let post: ?Post = posts.get(key);  // Buscamos la publicación usando la clave proporcionada.

    switch(post) {
      case (null) {  // Si no encontramos el post con esa clave.
        Debug.print("Cannot find post.");  // Imprimimos un mensaje de error.
        return false;  // Retornamos falso porque no se pudo encontrar el post.
      };
      case (_) {  // Si encontramos el post, lo eliminamos.
        ignore posts.remove(key);  // Eliminamos el post del HashMap usando su clave.
        Debug.print("Post deleted.");  // Imprimimos un mensaje de éxito.
        return true;  // Retornamos verdadero porque el post fue eliminado exitosamente.
      };
    };
  };
};


// dfx start --background --clean

// dfx deploy 