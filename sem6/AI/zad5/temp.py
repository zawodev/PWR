# autorem kodu nie jestem ja
import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import transforms
from facenet_pytorch import InceptionResnetV1
import numpy as np
import random
from sklearn.datasets import fetch_lfw_pairs
from sklearn.metrics import accuracy_score, precision_score, recall_score, roc_auc_score

# Device configuration
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Download LFW pairs dataset
lfw_train = fetch_lfw_pairs(subset='train', color=True, resize=0.5, download_if_missing=True)
lfw_test  = fetch_lfw_pairs(subset='test',  color=True, resize=0.5, download_if_missing=True)

# Preprocessing: transform numpy arrays to normalized tensors
transform = transforms.Compose([
    transforms.ToPILImage(),
    transforms.Resize((160,160)),
    transforms.ToTensor(),
    transforms.Normalize([0.5,0.5,0.5],[0.5,0.5,0.5])
])

# Embedding model (FaceNet)
facenet = InceptionResnetV1(pretrained='vggface2').eval().to(device)

def embed_from_array(arr):
    img_tensor = transform(arr).to(device)
    with torch.no_grad():
        emb = facenet(img_tensor.unsqueeze(0))
    return emb.squeeze(0)

# Prepare dataset: compute diff vectors and labels
def prepare_pairs(pairs, labels, sample_size=None, seed=None):
    total = len(labels)
    idxs = list(range(total))
    if sample_size:
        if sample_size > total:
            sample_size = total
        random.seed(seed)
        idxs = random.sample(idxs, sample_size)
    X, y = [], []
    for i in idxs:
        img1, img2 = pairs[i]
        emb1 = embed_from_array(img1)
        emb2 = embed_from_array(img2)
        diff = torch.abs(emb1 - emb2)
        X.append(diff)
        y.append(labels[i])
    X = torch.stack(X).to(device)
    y = torch.tensor(y, dtype=torch.long).to(device)
    return X, y

# MLP model
def make_mlp(input_dim=512):
    return nn.Sequential(
        nn.Linear(input_dim, 256), nn.ReLU(),
        nn.Linear(256, 64),  nn.ReLU(),
        nn.Linear(64, 2)
    ).to(device)

# Training loop
def train_model(X, y, lr=1e-3, epochs=20):
    model = make_mlp()
    optimizer = optim.Adam(model.parameters(), lr=lr)
    criterion = nn.CrossEntropyLoss()
    for _ in range(epochs):
        model.train()
        optimizer.zero_grad()
        logits = model(X)
        loss = criterion(logits, y)
        loss.backward()
        optimizer.step()
    return model

# Evaluation metrics
def eval_model(model, X, y):
    model.eval()
    with torch.no_grad():
        logits = model(X)
        probs = torch.softmax(logits, dim=1)[:,1].cpu().numpy()
        preds = torch.argmax(logits, dim=1).cpu().numpy()
    y_true = y.cpu().numpy()
    return {
        'accuracy': accuracy_score(y_true, preds),
        'precision': precision_score(y_true, preds),
        'recall': recall_score(y_true, preds),
        'roc_auc': roc_auc_score(y_true, probs)
    }

# Main experiments
if __name__ == '__main__':
    train_sizes = [10, 100, 500, 1000, 5000]
    lrs         = [1e-4, 5e-4, 1e-3, 5e-3, 1e-2]
    epochs_list = [5, 10, 20, 50, 100]

    # Prepare test set (200 pairs max)
    test_X, test_y = prepare_pairs(lfw_test.pairs, lfw_test.target, sample_size=200, seed=42)

    # 1) Vary train size
    results_size = {}
    for N in train_sizes:
        X_tr, y_tr = prepare_pairs(lfw_train.pairs, lfw_train.target, sample_size=N, seed=1)
        mdl = train_model(X_tr, y_tr, lr=1e-3, epochs=20)
        results_size[N] = eval_model(mdl, test_X, test_y)
        print(f"Train size={N} (used={y_tr.size(0)}): {results_size[N]}")

    # 2) Vary learning rate (1000 pairs or max available, 20 epochs)
    X_1000, y_1000 = prepare_pairs(lfw_train.pairs, lfw_train.target, sample_size=1000, seed=2)
    results_lr = {}
    for lr in lrs:
        mdl = train_model(X_1000, y_1000, lr=lr, epochs=20)
        results_lr[lr] = eval_model(mdl, test_X, test_y)
        print(f"LR={lr}: {results_lr[lr]}")

    # 3) Vary epochs (1000 pairs or max available, lr=1e-3)
    results_epochs = {}
    for ep in epochs_list:
        mdl = train_model(X_1000, y_1000, lr=1e-3, epochs=ep)
        results_epochs[ep] = eval_model(mdl, test_X, test_y)
        print(f"Epochs={ep}: {results_epochs[ep]}")

    # Save results
    import json
    with open('results.json', 'w') as f:
        json.dump({'size': results_size, 'lr': results_lr, 'epochs': results_epochs}, f, indent=2)
    print("Done.")