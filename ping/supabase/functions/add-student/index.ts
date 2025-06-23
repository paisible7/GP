import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  // Vérifier le token utilisateur (admin)
  const authHeader = req.headers.get("Authorization") ?? "";
  const jwt = authHeader.replace("Bearer ", "");
  const { data: { user }, error } = await supabase.auth.getUser(jwt);

  if (error || !user) {
    return new Response(JSON.stringify({ error: "Non authentifié" }), { status: 401 });
  }

  // Vérifier le rôle dans la table profiles
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();

  if (!profile || profile.role !== "admin") {
    return new Response(JSON.stringify({ error: "Non autorisé" }), { status: 403 });
  }

  // Récupérer les infos de l'étudiant à créer
  const body = await req.json();
  const { email, name, password, promotion, filiere } = body;

  // Créer l'utilisateur dans Auth
  const { data: newUser, error: createUserError } = await supabase.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
  });

  if (createUserError || !newUser.user) {
    return new Response(JSON.stringify({ error: "Erreur création utilisateur", details: createUserError }), { status: 400 });
  }

  // Ajouter le profil
  await supabase.from("profiles").insert({
    id: newUser.user.id,
    nom_complet: name,
    role: "etudiant",
  });

  // Ajouter dans la table etudiants
  const etudiantData: any = {
    id: newUser.user.id,
    promotion,
    filiere: filiere ?? "",
  };
  await supabase.from("etudiants").insert(etudiantData);

  return new Response(JSON.stringify({ success: true }), { status: 200 });
});